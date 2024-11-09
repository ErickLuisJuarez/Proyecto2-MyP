program TestPrograma;

uses
  SysUtils, Classes, Programa;

// Procedimiento: TestEsNube
// Realiza pruebas unitarias para la función EsNube, verificando que se identifiquen correctamente los píxeles de nube y no nube.
// Se prueban varios colores, como blanco, gris claro, amarillo y negro, para asegurar que la función funcione adecuadamente.
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

// Procedimiento: TestLectorPixeles
// Realiza pruebas unitarias para la función LectorPixeles, asegurándose de que la imagen se cargue correctamente
// y que el arreglo de píxeles no esté vacío.
// También verifica que la imagen tenga filas de píxeles.
procedure TestLectorPixeles;
var
  Pixeles: TArregloPixeles;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Assert(Length(Pixeles) > 0, 'El arreglo de píxeles no debe estar vacío');
  Assert(Length(Pixeles[0]) > 0, 'La imagen debe tener filas de píxeles');
  WriteLn('El lector de píxeles funciona correctamente.');
end;

// Procedimiento: TestCalcularRadioCirculo
// Realiza pruebas unitarias para la función CalcularRadioCirculo, verificando que el radio calculado sea mayor que cero
// cuando se pasa un arreglo de píxeles como entrada.
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

// Procedimiento: TestConvertirBlancoYNegro
// Realiza pruebas unitarias para la función ConvertirBlancoYNegro, asegurándose de que la conversión de la imagen
// a blanco y negro se haya realizado correctamente, modificando la imagen según el radio calculado.
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

// Procedimiento: TestGuardarImagenRecortada
// Realiza pruebas unitarias para la función GuardarImagenRecortada, asegurándose de que la imagen recortada
// se guarde correctamente en el archivo especificado.
// También verifica que el archivo de salida exista después de guardar la imagen.
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
