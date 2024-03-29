{
Copyright (C) 2006-2009 Matteo Salvi and Shannara

Website: http://www.salvadorsoftware.com/

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
}

unit PropertyCat;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ulNodeDataTypes, FileUtil, Graphics;

type

  { TfrmPropertyCat }

  TfrmPropertyCat = class(TForm)
    edtName: TEdit;
    lbName: TLabel;
    btnCancel: TButton;
    btnOk: TButton;
    Panel1: TPanel;
    lbPathIcon: TLabel;
    edtPathIcon: TEdit;
    btnBrowseIcon: TButton;
    OpenDialog1: TOpenDialog;
    cbHideSoftware: TCheckBox;
    procedure btnBrowseIconClick(Sender: TObject);
    procedure edtNameEnter(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure LoadNodeData(AData: TvCategoryNodeData);
    procedure SaveNodeData(AData: TvCategoryNodeData);
  public
    { Public declarations }
    class function Edit(AOwner: TComponent; NodeData: PBaseData): TModalResult;
  end;

var
  frmPropertyCat : TfrmPropertyCat;

implementation

uses
  appConfig, udImages, ulSysUtils, Main, ulCommonUtils;

{$R *.lfm}

class function TfrmPropertyCat.Edit(AOwner: TComponent; NodeData: PBaseData): TModalResult;
begin
  Result := mrCancel;
  if not Assigned(NodeData) then
    ShowMessage(msgErrGeneric)
  else
    with TfrmPropertyCat.Create(AOwner) do
      try
        LoadNodeData(TvCategoryNodeData(NodeData.Data));
        FormStyle := frmMain.FormStyle;
        ShowModal;
        if ModalResult = mrOK then
          SaveNodeData(TvCategoryNodeData(NodeData.Data));
        Result := ModalResult;
      finally
        Free;
      end;
end;

procedure TfrmPropertyCat.btnBrowseIconClick(Sender: TObject);
begin
  OpenDialog1.Filter     := 'Files supported (*.ico;*.exe)|*.ico;*.exe|All files|*.*';
  OpenDialog1.InitialDir := ExtractFileDir(RelativeToAbsolute(edtPathIcon.Text));
  if (OpenDialog1.Execute) then
    edtPathIcon.text := AbsoluteToRelative(OpenDialog1.FileName);
  SetCurrentDirUTF8(SUITE_WORKING_PATH); 
end;

procedure TfrmPropertyCat.edtNameEnter(Sender: TObject);
begin
  TEdit(Sender).Color := clDefault;
end;

procedure TfrmPropertyCat.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPropertyCat.btnOkClick(Sender: TObject);
begin
  CheckPropertyName(edtName);
end;

procedure TfrmPropertyCat.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ((ModalResult = mrOK) and (Trim(edtName.Text) <> ''))
           or (ModalResult = mrCancel);
end;

procedure TfrmPropertyCat.LoadNodeData(AData: TvCategoryNodeData);
begin
  edtName.Text     := AData.name;
  edtPathIcon.Text := AData.PathIcon;
  cbHideSoftware.Checked := AData.HideFromMenu;
end;

procedure TfrmPropertyCat.SaveNodeData(AData: TvCategoryNodeData);
begin
  AData.Name       := StringReplace(edtName.Text, '&&', '&', [rfIgnoreCase,rfReplaceAll]);
  AData.Name       := StringReplace(AData.Name, '&', '&&', [rfIgnoreCase,rfReplaceAll]);
  AData.PathIcon   := edtPathIcon.Text;
  ImagesDM.DeleteCacheIcon(AData);
  AData.ImageIndex := ImagesDM.GetIconIndex(TvBaseNodeData(AData));
  AData.HideFromMenu := cbHideSoftware.Checked;
  AData.Changed    := true;
end;

end.
