unit BaseController;

interface

uses
  System.SysUtils, Web.HTTPApp, View, IdCustomHTTPServer;

type
  TBaseController = class
  private
    FRequest: TWebRequest;
    FResponse: TWebResponse;
    FActionPath: string;
    procedure SetRequest(const Value: TWebRequest);
    procedure SetResponse(const Value: TWebResponse);
    procedure SetActionPath(const Value: string);
  protected
  public
    View: TView;
    Error: Boolean;
    function isPOST:Boolean;
    function isGET:Boolean;
    function isNil(text: string): Boolean; //�жϿ�ֵ
    function isNotNil(text: string): Boolean; //�жϿ�ֵ
    function Interceptor: boolean; //������
    procedure CreateView();
    constructor Create();
    destructor Destroy; override;
    function AppPath:string;//��ȡ��Ŀ����·��
    property Request: TWebRequest read FRequest write SetRequest;
    property Response: TWebResponse read FResponse write SetResponse;
    property ActionPath: string read FActionPath write SetActionPath;
  end;

implementation

{ TBaseController }
function TBaseController.Interceptor: boolean;  //������
var
  url: string;
begin
  Result := false;
  with View do
  begin
    url := LowerCase(Request.PathInfo);
    if (Error) then
    begin
      Result := true;
      exit;
    end;
    if (url <> '/') and (url <> '/index') and (url <> '/check') and (url <> '/checknum') and (url <> '/favicon.ico') then
    begin
      if (SessionGet('username') = '') then
      begin
        Result := true;
        Response.Content := '<script>window.location.href=''/'';</script>';
        Response.SendResponse;
      end;
    end;
  end;
end;

function TBaseController.isGET: Boolean;
begin
   Result:=Request.MethodType = mtGet;
end;

function TBaseController.isNil(text: string): Boolean;
begin
  if (Trim(text) = '') then
    Result := true
  else
    Result := false;
end;

function TBaseController.isNotNil(text: string): Boolean;
begin
  Result:=not isNil(text);
end;

function TBaseController.isPOST: Boolean;
begin
  Result:=Request.MethodType = mtPost;
end;

procedure TBaseController.SetActionPath(const Value: string);
begin
  FActionPath := Value;
end;

procedure TBaseController.SetRequest(const Value: TWebRequest);
begin
  FRequest := Value;
end;

procedure TBaseController.SetResponse(const Value: TWebResponse);
begin
  FResponse := Value;
end;

function TBaseController.AppPath: string;
begin
  Result:=WebApplicationDirectory;
end;

constructor TBaseController.Create();
begin
  View := nil;
  ActionPath := '';
end;

procedure TBaseController.CreateView;
begin
  try
    View := TView.Create(Response, Request, ActionPath);
  except
    on e: Exception do
    begin
      self.Response.Content := e.ToString;
      Error := true;
    end;
  end;
end;

destructor TBaseController.Destroy;
begin
  FreeAndNil(View);
  inherited;
end;

end.

