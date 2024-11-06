program TestBlancoYNegro;

uses
  SysUtils, Classes, BlancoYNegro;

procedure TestEsNube;
var
  Resultado: Boolean;
begin

  Resultado := EsNube(255, 255, 255);
  Assert(Resultado = False, 'El píxel blanco no debe ser una nube');

  Resultado := EsNube(245, 245, 245); 
  Assert(Resultado = True, 'El píxel gris claro debe ser una nube');


  Resultado := EsNube(255, 255, 0); 
  Assert(Resultado = False, 'El píxel amarillo no debe ser una nube');


  Resultado := EsNube(0, 0, 0); 
  Assert(Resultado = False, 'El píxel negro no debe ser una nube');
end;


begin
  TestEsNube;
  WriteLn('Todas las pruebas han pasado con éxito.');
end.
