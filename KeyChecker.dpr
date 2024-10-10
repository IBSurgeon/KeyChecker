// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
library KeyChecker;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  windows,
  System.SysUtils,
  System.Classes;

{$R *.res}


const DEBUG_ALERT = false;



procedure LOG(const FileName: string; S: string);
const
  FILE_APPEND_DATA = 4;
  OPEN_ALWAYS = 4;
var
  Handle: THandle;
  Stream: THandleStream;
begin
  Handle := CreateFile(PChar(FileName),
    FILE_APPEND_DATA, // Append data to the end of file
    0, nil,
    OPEN_ALWAYS, // If the specified file exists, the function succeeds and the last-error code is set to ERROR_ALREADY_EXISTS (183).
                 // If the specified file does not exist and is a valid path to a writable location, the function creates a file and the last-error code is set to zero.
    FILE_ATTRIBUTE_NORMAL, 0);

  if Handle <> INVALID_HANDLE_VALUE then
  try
    Stream := THandleStream.Create(Handle);
    try
      S := S + #13#10;
      Stream.WriteBuffer(S[1], Length(S) * SizeOf(Char));
    finally
      Stream.Free;
    end;
  finally
    FileClose(Handle);
  end
  else
    RaiseLastOSError;
end;




procedure CheckKey(keyName: PAnsiChar; exeName: PAnsiChar; keyLen: Cardinal; keyValue: PByte); cdecl; export;
var
  bIn, b4Out:Byte;
  outpFName:String;
  i:Integer;
  text4Msg:String;
  fsLogFile :TFileStream;
begin

  SetLength(outpFName, MAX_PATH);
  i := windows.GetTempPath(MAX_PATH, PChar(outpFName));
  SetLength(outpFName, i);
  outpFName:=outpFName+'\fbkey.trace';
  if DEBUG_ALERT then begin
    text4Msg := 'log file to write: '+outpFName;
    MessageBox(0, PChar(text4Msg), PChar('KeyChecker'), MB_ICONINFORMATION or MB_OK	or MB_TASKMODAL or MB_SETFOREGROUND or MB_TOPMOST);
  end;


  try
    text4Msg := DateTimeToStr(now) + ' ['+exeName+'] key ['+keyName+'] keyLen:'+IntToStr(keyLen)+#13#10;
    LOG(outpFName, text4Msg);
  except
    on E: Exception do begin
      fsLogFile:=nil;
      if DEBUG_ALERT then begin
        text4Msg:='Can''t create file: '+#13#10+'"'+outpFName+'"'+#13#10+E.Message;
        MessageBox(0, PChar(text4Msg), PChar('KeyChecker'), MB_ICONERROR or MB_OK	or MB_TASKMODAL or MB_SETFOREGROUND or MB_TOPMOST);
      end;
    end;
  end;


	if uppercase(keyName) = 'RED' then begin
    LOG(outpFName, 'convert key RED'#13#10);
		while(keyLen > 0) do begin
			keyLen := keyLen - 1;
      bIn := keyValue[keyLen];

      //some logic to convert
      b4Out := not bIn;

			keyValue[keyLen] := b4Out;
		end
	end;
end;




exports
  CheckKey;


begin




end.
