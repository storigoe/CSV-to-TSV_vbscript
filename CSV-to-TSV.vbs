' カンマ区切り ダブルクォーテーション囲みのCSVをタブ区切り囲みなしの形式に変更する
' カラム内容の編集・並び替え可
'
Option Explicit

Dim Args
Dim FS,buf,arrLines
Dim objSJIS,objUTF8,objNew,objNew2
Dim array,i,colName,rowCount,sortRow(),writeRow
Dim delFO

'書き込みモード、読み込みモード
Const ForReading = 1, ForWriting = 2
'現在日時：YYYYmmddHHmmss
Dim nowTime
nowTime = Replace(Replace(Replace(Now(), "/", ""), ":", ""), " ", "_")
Set Args = WScript.Arguments

If Args.Count < 1 Then
  WScript.Echo "本スクリプトにCSVファイルをドラッグ&ドロップして処理実行開始"
  WScript.Quit
End If
With CreateObject("Scripting.FileSystemObject")
  'Args(0) :: file full pass
  Set FS = CreateObject("Scripting.FileSystemObject").GetFolder(CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName))
  'FS :: file directory
  Select Case LCase(.GetExtensionName(Args(0)))
  '対応形式
    Case "txt", "csv", "tsv"
      Set objUTF8 = CreateObject("ADODB.Stream")
      objUTF8.Type = 2
      objUTF8.Charset = "UTF-8"
      objUTF8.Open
      objUTF8.LoadFromFile Args(0)

      Set objSJIS = CreateObject("ADODB.Stream")
      objSJIS.Type = 2
      objSJIS.Charset = "Shift_JIS"
      objSJIS.Open
      buf = objUTF8.ReadText

      'もとからあるCRLFを削除、LFをCRLFに
      buf = Replace(buf, vbCrLf, "")
      buf = Replace(buf, vbLf, vbCrLf)
      'adWriteChar	0	文字を書き込む
      'adWriteLine	1	文字を改行付きで書き込む
      objSJIS.WriteText buf, 1

      '一時保存しておく
      objSJIS.SaveTofile FS & "\" & nowTime & "_tmp.csv", ForWriting
      objSJIS.Close
      objUTF8.Close
      set objSJIS = Nothing
      set objUTF8 = Nothing

      'CSV項目の編集をここから
      Set objNew = CreateObject("ADODB.Stream")
      objNew.Type = 2
      objNew.Charset = "Shift_JIS"
      objNew.Mode = 3 '読み取り/書き込みモード
      objNew.Type = 2 'テキストデータ
      objNew.Open
      objNew.LoadFromFile FS & "\" & nowTime & "_tmp.csv"

      Set objNew2 = CreateObject("ADODB.Stream")
      objNew2.Type = 2
      objNew2.Charset = "Shift_JIS"
      objNew2.Mode = 3 '読み取り/書き込みモード
      objNew2.Type = 2 'テキストデータ
      objNew2.Open

      'カラムを1つずつ処理する
      rowCount = 0
      Do Until objNew.EOS
        arrLines = objNew.ReadText(-2)
        array = Split(arrLines,",")

        For i = 0 To UBound(array)
          array(i) = Replace(array(i), """", "")
          If rowCount = 1 Then
            colName = array
          End If
          If i <> UBound(array) Then
            'ヘッダで内容判定、必要な変換処理を入れる
            If colName(i) = "" Then
            ElseIf colName(i) = "" Then
              '処理
            ElseIf colName(i) = "" Then
              '処理
            ElseIf colName(i) = "" Then
              '処理
            Else
              '処理
            End If
          End If
          'tsv形式
          '任意の順で並び替え（手動）
          writeRow = writeRow & array(0) & vbTab
          writeRow = writeRow & array(1) & vbTab
          writeRow = writeRow & array(2) & vbTab
          writeRow = writeRow & array(3) & vbTab
          writeRow = writeRow & array(4) & vbTab
          writeRow = writeRow & array(5) & vbTab
          'カラム数分追記
          '最終列はtabを入れずに改行
          writeRow = writeRow & array(UBound(array))
          objNew2.WriteText writeRow, 1
        Next

        rowCount = rowCount + 1
      Loop

      '保存・拡張子指定
      objNew2.SaveTofile FS & "\" & nowTime & ".csv", ForWriting
      objNew.Close
      set objNew = Nothing
      objNew2.Close
      set objNew2 = Nothing

      '一時ファイル削除
      Set delFO = CreateObject("Scripting.FileSystemObject")
      delFO.DeleteFile FS & "\" & nowTime & "_tmp.csv"
      Set delFO = Nothing

    Case Else
      WScript.Echo "未対応のファイル形式です。"
      WScript.Quit
  End Select
End With
Set Args = Nothing
