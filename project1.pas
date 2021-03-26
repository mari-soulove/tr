 program project1;
const
 kwCount=10;
 kwTable:array[1..kwCount] of string[7]=('INPUT','OUTPUT','IF','THEN',
 'ELSE','WHILE','DO','FUNC','RET','HALT'); {ключевые слова}
var
 idCount, consCount, funCount: integer;{число идентификаторов, констант, функций
(меток)}
 curState, curTerm, prevTerm, prevComState: char; {текущее состояние; текущий символ}
 idTable: array[1..200] of string[15]; {таблица идентификаторов}
 consTable: array[1..200] of integer; {таблица констант}
 funTable: array[1..30] of string[15]; {таблица функций}
 inFile, outFile, consTableFile: Text; {файлы: входной (исходная программа); выходной (1-
е внутреннее представление); список констант}
 str, curLex: string[50];
 k,i: integer;
function kwIndex(lex: string): integer;
var
 i: integer;
begin
 kwIndex:=0;
 for i:=1 to kwCount do if lex=kwTable[i] then begin
 kwIndex:=i;
 break
 end
end;
function idIndex(lex: string): integer;
var
 i: integer;
begin
 idIndex:=0;
 for i:=1 to idCount do if lex=idTable[i] then begin
 idIndex:=i;
 break
 end
end;
function funIndex(lex: string): integer;
var
 i: integer;
begin
 funIndex:=0;
 for i:=1 to funCount do if lex=funTable[i] then begin
 funIndex:=i;
 break
 end
end;
begin
 writeln('input source file name:');
 readln(str);
 assign(inFile, str+'.src');
 reset(inFile);
 assign(outFile,str+'.ala');
 rewrite(outFile);
 curState:='S';
 curLex:='';
 idCount:=0;
 consCount:=0;
 while not eof(inFile) do begin
 read(inFile, curTerm);
 if (curTerm<>chr(10))and(curTerm<>chr(13)) then case curState of {перевод строки Chr(13)
и возврат каретки Chr(10)}
 'S': begin
 case curTerm of
 'a'..'z', 'A'..'Z': begin
 curState:='A';
 curLex:=curLex+curTerm
 end;
 '0'..'9': begin
 curState:='B';
 curLex:=curLex+curTerm
 end;
 ' ': begin
 curState:='S';
 end;
 ';','+','-','/','\','(',')','[',']','=','*','{','}': begin
 curState:='S';

 write(outFile, curTerm);
 end;
 ':': begin
 curState:='C';
 end;
 '<','>': begin
 curState:='D';
 prevTerm:=curTerm;
 end;
 '!': begin
 curState:='E';
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'A': begin
 case curTerm of
 'a'..'z', 'A'..'Z','0'..'9': begin
 curState:='A';
 curLex:=curLex+curTerm
 end;
 ' ': begin
 curState:='I';
 end;
 ';','+','-','/','\',')','[',']','=','*','{','}': begin
 curState:='S';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 write(outFile, curTerm);
 curLex:='';
 end;
 '(': begin
 curState:='S';
 k:=funIndex(curLex);
 if k<>0 then write(outFile,'F',k) else begin
 inc(funCount);
 funTable[funCount]:=curLex;
 write(outFile,'F',funCount);
 end;
 write(outFile, curTerm);
 curLex:='';
 end;
 ':': begin
 curState:='C';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 end;
 '<','>': begin
 curState:='D';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 prevTerm:=curTerm;
 end;
 '!': begin
 curState:='E';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 write('error');
 halt
 end;
 end;
 end;
 'B': begin
 case curTerm of
 '0'..'9': begin
 curState:='B';
 curLex:=curLex+curTerm
 end;
 ' ': begin
 curState:='S';
 inc(consCount);
 val(curLex,k,i);
 consTable[consCount]:=k;
 write(outFile, 'C', consCount);
 curLex:='';
 end;
 ';','+','-','/','\',')',']','=','*','}': begin
 curState:='S';
 inc(consCount);
 val(curLex,k,i);
 consTable[consCount]:=k;
 write(outFile, 'C', consCount);
 write(outFile, curTerm);
 curLex:='';
 end;
 '<','>': begin
 curState:='D';
 inc(consCount);
 val(curLex,k,i);
 consTable[consCount]:=k;
 write(outFile, 'C', consCount);
 curLex:='';
 prevTerm:=curTerm;
 end;
 '!': begin
 curState:='E';
 inc(consCount);
 val(curLex,k,i);
 consTable[consCount]:=k;
 write(outFile, 'C', consCount);
 curLex:='';
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'C': begin
 case curTerm of
 '=': begin
 curState:='S';
 write(outFile, '@');
 curLex:='';
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'D': begin
 case curTerm of
 'a'..'z','A'..'Z': begin
 curState:='A';
 write(outFile, prevTerm);
 curLex:=curLex+curTerm
 end;
 '0'..'9': begin
 curState:='B';
 write(outFile, prevTerm);
curLex:=curLex+curTerm
 end;
 '=': begin
 curState:='S';
 if prevTerm='<' then write(outFile,'~') else write(outFile,'$');
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'E': begin
 case curTerm of
 '=': begin
 curState:='S';
 write(outFile,'^');
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'F': begin
 case curTerm of
 '*': curState:='G';
 else begin
 writeln('error');
 halt
 end
 end
 end;
 'G': begin
 case curTerm of
 '*': curState:='H';
 end
 end;
 'H': begin
 case curTerm of
 '|': curState:=prevComState;
 else curState:='G'
 end
 end;
 'I': begin
 case curTerm of
 'a'..'z', 'A'..'Z': begin
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 curState:='A';
 curLex:=curLex+curTerm
 end;
 '0'..'9': begin
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 curState:='B';
 curLex:=curLex+curTerm
 end;
 ' ': begin
 curState:='I';
 end;
 ';','+','-','/','\',')','[',']','=','*','{','}': begin
 curState:='S';
 k:=kwIndex(curLex);
if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 write(outFile, curTerm);
 curLex:='';
 end;
 '(': begin
 curState:='S';
 k:=funIndex(curLex);
 if k<>0 then write(outFile,'F',k) else begin
 inc(funCount);
 funTable[funCount]:=curLex;
 write(outFile,'F',funCount);
 end;
 write(outFile, curTerm);
 curLex:='';
 end;
 ':': begin
 curState:='C';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 end;
 '<','>': begin
 curState:='D';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 prevTerm:=curTerm;
 end;
 '!': begin
 curState:='E';
 k:=kwIndex(curLex);
 if k<>0 then write(outFile,'K',k) else begin
 k:=idIndex(curLex);
 if k=0 then begin
 inc(idCount);
 idTable[idCount]:=curLex;
 write(outFile,'I', idCount)
 end else write(outFile,'I',k)
 end;
 curLex:='';
 end;
 '|': begin
 prevComState:=curState;
 curState:='F';
 end;
 else begin
 write('error');
 halt
 end;
 end;
 end
 end
 end;
 assign(consTableFile, str+'.cta');
 rewrite(consTableFile);
 writeln(consTableFile, consCount);
 for i:=1 to consCount do writeln(consTableFile,consTable[i]);
 close(consTableFile);
 close(inFile);
 close(outFile)
end.
