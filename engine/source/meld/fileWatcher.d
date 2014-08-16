module meld.fileWatcher;

import std.string;

static class FileWatcher
{
	alias Callback = void delegate(string file);

	static class Watcher
	{
		version(Windows)
		{
			import core.sys.windows.windows;
			import core.stdc.stdlib;
			import core.stdc.string;
			import std.conv;

			struct FILE_NOTIFY_INFORMATION {
				DWORD NextEntryOffset;
				DWORD Action;
				DWORD FileNameLength;
				WCHAR FileName[1];
			}

			extern(Windows)
			{
				alias VOID function(DWORD dwErrorCode, DWORD dwNumberOfBytesTransfered, OVERLAPPED* lpOverlapped) LPOVERLAPPED_COMPLETION_ROUTINE;
				
				alias fReadDirectoryChangesW = BOOL function(HANDLE hDirectory, LPVOID lpBuffer, DWORD nBufferLength, BOOL bWatchSubtree,
				                         DWORD dwNotifyFilter, DWORD* lpBytesReturned, OVERLAPPED* lpOverlapped, LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
				static fReadDirectoryChangesW ReadDirectoryChangesW;

				alias fCreateIoCompletionPort = HANDLE function(HANDLE FileHandle, HANDLE ExistingCompletionPort, ULONG_PTR CompletionKey, DWORD NumberOfConcurrentThreads);
				static fCreateIoCompletionPort CreateIoCompletionPort;

				alias fGetQueuedCompletionStatus = BOOL function(HANDLE CompletionPort, DWORD* lpNumberOfBytes, PULONG_PTR lpCompletionKey, OVERLAPPED** lpOverlapped, DWORD dwMilliseconds);
				static fGetQueuedCompletionStatus GetQueuedCompletionStatus;

				alias fCancelIo = BOOL function(HANDLE hFile);
				static fCancelIo CancelIo;

				static this()
				{
					HMODULE libHandle = LoadLibraryA("kernel32.dll");
					ReadDirectoryChangesW = cast(fReadDirectoryChangesW)GetProcAddress(libHandle, "ReadDirectoryChangesW");
					CreateIoCompletionPort = cast(fCreateIoCompletionPort)GetProcAddress(libHandle, "CreateIoCompletionPort");
					GetQueuedCompletionStatus = cast(fGetQueuedCompletionStatus)GetProcAddress(libHandle, "GetQueuedCompletionStatus");
					CancelIo = cast(fCancelIo)GetProcAddress(libHandle, "CancelIo");
				}
			}

			HANDLE m_directoryHandle, m_completionPort;
			Callback m_callback;
			OVERLAPPED m_overlapped;
			void[4096] m_buffer = void;
			string m_directory;

			this(string directory, Callback callback)
			{
				m_directory = directory;
				m_directoryHandle = CreateFileA(
					directory.toStringz, 
					FILE_LIST_DIRECTORY, 
					FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE,
					null,
					OPEN_EXISTING,
					FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED,
					null);
				assert(m_directoryHandle != INVALID_HANDLE_VALUE);

				m_completionPort = CreateIoCompletionPort(m_directoryHandle, null, 0, 1);
				assert(m_completionPort != INVALID_HANDLE_VALUE);

				m_callback = callback;

				DoRead();
			}

			~this()
			{
				CancelIo(m_directoryHandle);
				CloseHandle(m_completionPort);
				CloseHandle(m_directoryHandle);
			}

			void DoRead()
			{
				memset(&m_overlapped, 0, m_overlapped.sizeof);
				ReadDirectoryChangesW(m_directoryHandle, m_buffer.ptr, m_buffer.length, true,
					FILE_NOTIFY_CHANGE_LAST_WRITE, null, &m_overlapped, null);
			}

			void Update()
			{
				bool[string] notifyList;

				OVERLAPPED* lpOverlapped;
				uint numberOfBytes;
				ULONG_PTR completionKey;
				while( GetQueuedCompletionStatus(m_completionPort, &numberOfBytes, &completionKey, &lpOverlapped, 0) != 0)
				{
					//Copy the buffer
					assert(numberOfBytes > 0);
					void[] buffer = alloca(numberOfBytes)[0..numberOfBytes];
					buffer[0..$] = m_buffer[0..numberOfBytes];

					//Reissue the read request
					DoRead();

					//Process the messages
					auto info = cast(const(FILE_NOTIFY_INFORMATION)*)buffer.ptr;
					while(true)
					{
						const(WCHAR)[] directory = info.FileName.ptr[0..(info.FileNameLength/2)];
						int bytesNeeded = WideCharToMultiByte(CP_UTF8, 0, directory.ptr, to!int(directory.length), null, 0, null, null);
						if(bytesNeeded > 0)
						{
							char[] dir = (cast(char*)alloca(bytesNeeded))[0..bytesNeeded];
							WideCharToMultiByte(CP_UTF8, 0, directory.ptr, to!int(directory.length), dir.ptr, to!int(dir.length), null, null);

							string changedFile = to!string(dir);
							if (changedFile !in notifyList)
							{
								m_callback(m_directory ~ "\\" ~ to!string(dir));
								notifyList[changedFile] = true;	
							}
						}
						if(info.NextEntryOffset == 0)
							break;
						else
							info = cast(const(FILE_NOTIFY_INFORMATION)*)((cast(void*)info) + info.NextEntryOffset);
					}
				}
			}
		}
		else
		{
			this(string directory, Callback callback)
			{

			}

			void Update()
			{
				
			}
		}
	}

	static Watcher contentWatcher = null;
	alias void delegate() FileChangeCallback;

	static FileChangeCallback[string] callbackList;

	static void Watch(string sourceFile, void delegate() callback)
	{
		import std.stdio : writeln;
		if (contentWatcher is null)
		{
			contentWatcher = new Watcher("data", (changedFile)
			{
				changedFile = translate(changedFile, ['\\': '/']);
				writeln(changedFile ~ " changed");

				FileChangeCallback* callback = changedFile in callbackList;
				if (callback)
					(*callback)();
			});
		}
		writeln("Listening for changes to " ~ sourceFile);
		callbackList[sourceFile] = callback;
	}

	static void Update()
	{
		if (contentWatcher !is null)
			contentWatcher.Update();
	}
}
