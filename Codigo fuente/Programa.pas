unit Programa;

interface

uses
  SysUtils, FPImage, FPReadJPEG, FPReadPNG, FPWritePNG, Classes, Math;

type
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

function LectorPixeles(const NombreArchivo: String): TArregloPixeles;
function Min(A, B: Integer): Integer;
function CalcularRadioCirculo(const Pixeles: TArregloPixeles): Integer;
function EsNube(R, G, B: Byte): Boolean;
function ConvertirBlancoYNegro(const Pixeles: TArregloPixeles; const Radio: Integer): TArregloPixeles;
function CalcularIndice(const Pixeles: TArregloPixeles; const Radio: Integer): Real;
procedure GuardarImagenRecortada(const Pixeles: TArregloPixeles; const Salida: string);

implementation

//Función: Lector de Pixeles.
// Carga una imagen y extrae los valores de los pixeles en un arreglo, que es una matriz
//de registros con los componentes de cada color.
// Parámetros: NombreArchivo: String - El nombre del archivo de imagen que se va a cargar.
// Devuelve: Una matriz bidimensional (TArregloPixeles) que contiene los valores de los píxeles de la imagen cargada.
function LectorPixeles(const NombreArchivo: String): TArregloPixeles;
var
  Imagen: TFPMemoryImage;
  LectorImagen: TFPCustomImageReader;
  Columna, Fila: Integer;
  ColorPixel: TFPColor;
  ImagenPixeles: TArregloPixeles;
begin
  Imagen := TFPMemoryImage.Create(0, 0);

  if LowerCase(ExtractFileExt(NombreArchivo)) = '.jpg' then
    LectorImagen := TFPReaderJPEG.Create
  else if LowerCase(ExtractFileExt(NombreArchivo)) = '.png' then
    LectorImagen := TFPReaderPNG.Create
  else
  begin
    WriteLn('Formato de archivo no soportado: ', NombreArchivo);
    Exit;
  end;

  Imagen.LoadFromFile(NombreArchivo, LectorImagen);
  SetLength(ImagenPixeles, Imagen.Width, Imagen.Height);

  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      ColorPixel := Imagen.Colors[Columna, Fila];
      ImagenPixeles[Columna, Fila].Rojo := ColorPixel.Red shr 8;
      ImagenPixeles[Columna, Fila].Verde := ColorPixel.Green shr 8;
      ImagenPixeles[Columna, Fila].Azul := ColorPixel.Blue shr 8;
    end;

  LectorImagen.Free;
  Imagen.Free;

  LectorPixeles := ImagenPixeles;
end;

//Función: Minima.
// Compara dos valores enteros y devuelve el menor.
// Parámetros: A, B: Integer - Los valores a comparar.
// Devuelve: El valor más pequeño de A y B.
function Min(A, B: Integer): Integer;
begin
  if A < B then
    Min := A
  else
    Min := B;
end;

//Función: CalcularRadioCirculo.
// Calcula el radio de un círculo que rodea el área de interés dentro de la imagen,
// basado en los píxeles cercanos al centro de la imagen que representan la zona libre de nubes.
// Parámetros: Pixeles: TArregloPixeles - Los valores de los píxeles de la imagen.
// Devuelve: Un valor entero que representa el radio del círculo que rodea la zona de interés.
function CalcularRadioCirculo(const Pixeles: TArregloPixeles): Integer;
var
  CentroX, CentroY, Columna, Fila: Integer;
  RadioIzquierdo, RadioDerecho, RadioArriba, RadioAbajo: Integer;
begin
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;

  RadioIzquierdo := CentroX;
  for Columna := CentroX downto 0 do
  begin
    if (Pixeles[Columna, CentroY].Rojo < 50) and 
       (Pixeles[Columna, CentroY].Verde < 50) and 
       (Pixeles[Columna, CentroY].Azul < 50) then
    begin
      RadioIzquierdo := CentroX - Columna;
      Break;
    end;
  end;

  RadioDerecho := Length(Pixeles) - CentroX;
  for Columna := CentroX to High(Pixeles) do
  begin
    if (Pixeles[Columna, CentroY].Rojo < 50) and 
       (Pixeles[Columna, CentroY].Verde < 50) and 
       (Pixeles[Columna, CentroY].Azul < 50) then
    begin
      RadioDerecho := Columna - CentroX;
      Break;
    end;
  end;

  RadioArriba := CentroY;
  for Fila := CentroY downto 0 do
  begin
    if (Pixeles[CentroX, Fila].Rojo < 50) and 
       (Pixeles[CentroX, Fila].Verde < 50) and 
       (Pixeles[CentroX, Fila].Azul < 50) then
    begin
      RadioArriba := CentroY - Fila;
      Break;
    end;
  end;

  RadioAbajo := Length(Pixeles[0]) - CentroY;
  for Fila := CentroY to High(Pixeles[0]) do
  begin
    if (Pixeles[CentroX, Fila].Rojo < 50) and 
       (Pixeles[CentroX, Fila].Verde < 50) and 
       (Pixeles[CentroX, Fila].Azul < 50) then
    begin
      RadioAbajo := Fila - CentroY;
      Break;
    end;
  end;

  CalcularRadioCirculo := Min(Min(RadioIzquierdo, RadioDerecho), Min(RadioArriba, RadioAbajo));
end;

//Función: EsNube.
// Determina si un color en formato RGB corresponde a una nube según el modelo HSB.
// Parámetros: R, G, B: Byte - Los componentes rojo, verde y azul del color del píxel.
// Devuelve: Un valor booleano que indica si el color es de una nube o no.
function EsNube(R, G, B: Byte): Boolean;
var
  MaxVal, MinVal: Byte;
  Tono, Saturacion, Brillo: Real;
begin
  MaxVal := Max(Max(R, G), B);
  MinVal := Min(Min(R, G), B);
  Brillo := MaxVal / 255.0;

  if MaxVal = 0 then
    Saturacion := 0
  else
    Saturacion := 1 - (MinVal / MaxVal);

  if MaxVal = MinVal then
    Tono := 0
  else if MaxVal = R then
    Tono := 60 * (0 + (G - B) / (MaxVal - MinVal))
  else if MaxVal = G then
    Tono := 60 * (2 + (B - R) / (MaxVal - MinVal))
  else
    Tono := 60 * (4 + (R - G) / (MaxVal - MinVal));

  if Tono < 0 then
    Tono := Tono + 360;

  EsNube := (Brillo > 0.8) and (Saturacion < 0.2)
            and not ((Tono >= 200) and (Tono <= 220));
end;

//Procedimiento: ConvertirBlancoYNegro.
// Convierte los píxeles dentro del área delimitada por el radio calculado en blanco y negro,
// con los píxeles de nubes en blanco y el resto en negro.
// Parámetros: Pixeles: TArregloPixeles - Los valores de los píxeles de la imagen.
// Radio: Integer - El radio que delimita el área de interés.
// ConvertirBlancoYNegro: Convierte la imagen a blanco y negro
// Parámetros:
// - Pixeles: Arreglo con valores RGB de la imagen
// - Radio: Radio del círculo central donde se detectan las nubes
// Devuelve: El arreglo de píxeles con valores en blanco y negro
// Función añadida para contar píxeles totales y de nube, y calcular el índice de cobertura
function ConvertirBlancoYNegro(const Pixeles: TArregloPixeles; const Radio: Integer): TArregloPixeles;
var
  CentroX, CentroY, Columna, Fila: Integer;
  Blanco, Negro: TFPColor;
  DistanciaCuadrada: Integer;
  PixelesByN: TArregloPixeles;
begin
  Blanco.Red := 65535; Blanco.Green := 65535; Blanco.Blue := 65535;
  Negro.Red := 0; Negro.Green := 0; Negro.Blue := 0;
  SetLength(PixelesByN, Length(Pixeles), Length(Pixeles[0]));
  // Calcula el centro de la imagen
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;

  // Itera sobre cada píxel para identificar nubes y convertir a blanco y negro
  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      DistanciaCuadrada := Sqr(Columna - CentroX) + Sqr(Fila - CentroY);
      if DistanciaCuadrada <= Sqr(Radio) then
      begin
        if EsNube(Pixeles[Columna, Fila].Rojo, Pixeles[Columna, Fila].Verde, Pixeles[Columna, Fila].Azul) then
        begin
          PixelesByN[Columna, Fila].Rojo := Blanco.Red shr 8;
          PixelesByN[Columna, Fila].Verde := Blanco.Green shr 8;
          PixelesByN[Columna, Fila].Azul := Blanco.Blue shr 8;
        end
        else
        begin
          PixelesByN[Columna, Fila].Rojo := Negro.Red shr 8;
          PixelesByN[Columna, Fila].Verde := Negro.Green shr 8;
          PixelesByN[Columna, Fila].Azul := Negro.Blue shr 8;
        end;
      end;
    end;
  ConvertirBlancoYNegro := PixelesByN;
end;

//Procedimiento: GuardarImagenRecortada.
// Guarda la imagen modificada en un archivo de salida, recortada a la zona que contiene
// los píxeles de la imagen procesada (el círculo de interés).
// Parámetros: Pixeles: TArregloPixeles - Los valores de los píxeles de la imagen.
// Salida: String - El nombre del archivo de salida donde se guarda la imagen.
procedure GuardarImagenRecortada(const Pixeles: TArregloPixeles; const Salida: string);
var
  ImagenNueva: TFPMemoryImage;
  Columna, Fila: Integer;
begin
  ImagenNueva := TFPMemoryImage.Create(Length(Pixeles), Length(Pixeles[0]));
  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      ImagenNueva.Colors[Columna, Fila] := FPColor(Pixeles[Columna, Fila].Rojo shl 8, Pixeles[Columna, Fila].Verde shl 8, Pixeles[Columna, Fila].Azul shl 8);
    end;
  ImagenNueva.SaveToFile(Salida);
  ImagenNueva.Free;
end;

function CalcularIndice(const Pixeles: TArregloPixeles; const Radio: Integer): Real;
var
  CentroX, CentroY, Columna, Fila, TotalPixeles, PixelesNube: Integer;
  Blanco: TFPColor;
  DistanciaCuadrada: Integer;
begin
  Blanco.Red := 65535; Blanco.Green := 65535; Blanco.Blue := 65535;
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;
  TotalPixeles := 0;
  PixelesNube := 0;

  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      DistanciaCuadrada := Sqr(Columna - CentroX) + Sqr(Fila - CentroY);
      if DistanciaCuadrada <= Sqr(Radio) then
      begin
        TotalPixeles += 1;
        if (Pixeles[Columna, Fila].Rojo = Blanco.Red shr 8) and 
           (Pixeles[Columna, Fila].Verde = Blanco.Green shr 8) and 
           (Pixeles[Columna, Fila].Azul = Blanco.Blue shr 8) then;
              PixelesNube += 1;
      end;
    end;
  CalcularIndice := (PixelesNube / TotalPixeles) * 100;
end;
end.
