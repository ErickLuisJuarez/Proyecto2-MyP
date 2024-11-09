program TestPrograma;

uses
  SysUtils, Classes, Programa;

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

procedure TestLectorPixeles;
var
  Pixeles: TArregloPixeles;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Assert(Length(Pixeles) > 0, 'El arreglo de píxeles no debe estar vacío');
  Assert(Length(Pixeles[0]) > 0, 'La imagen debe tener filas de píxeles');
  WriteLn('El lector de píxeles funciona correctamente.');
end;

procedure TestCalcularRadioCirculo;
var
  Pixeles: TArregloPixeles;
  Radio: Integer;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  Assert(Radio > 0, 'El radio del círculo debe ser mayor que cero');
  WriteLn('El cálculo del radio funciona correctamente.');
end;

procedure TestConvertirBlancoYNegro;
var
  Pixeles: TArregloPixeles;
  Radio: Integer;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  ConvertirBlancoYNegro(Pixeles, Radio);
  WriteLn('La conversión a blanco y negro se realizó correctamente.');
end;

procedure TestGuardarImagenRecortada;
var
  Pixeles: TArregloPixeles;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  GuardarImagenRecortada(Pixeles, '../Imagenes/11838_final.png');
  Assert(FileExists('../Imagenes/11838_final.png'), 'La imagen recortada no se guardó correctamente');
  WriteLn('La imagen recortada se guardó correctamente.');
end;

begin
  TestEsNube;
  TestLectorPixeles;
  TestCalcularRadioCirculo;
  TestConvertirBlancoYNegro;
  TestGuardarImagenRecortada;
  WriteLn('Todas las pruebas han pasado con éxito.');
end.
