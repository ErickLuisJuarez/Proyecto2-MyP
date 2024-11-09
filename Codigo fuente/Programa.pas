program Programa;

uses
  SysUtils, FPImage, FPReadJPEG, FPReadPNG, FPWritePNG, Classes, Math;

type
  // Tipo de arreglo para almacenar los valores RGB de cada píxel de una imagen
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

// LectorPixeles: Lee una imagen y devuelve un arreglo con valores RGB de cada píxel
// Parámetros:
// - NombreArchivo: Ruta y nombre del archivo de la imagen a leer.
// Devuelve: Arreglo de píxeles con componentes RGB.
function LectorPixeles(const NombreArchivo: String): TArregloPixeles;
var
  Imagen: TFPMemoryImage; // Objeto para cargar una imagen en la memoria
  LectorImagen: TFPCustomImageReader; // Lector de imagen JPG o PNG
  Columna, Fila: Integer; // Variables para iterar sobre filas y columnas
  ColorPixel: TFPColor; // Variable para almacenar el color de cada pixel
  ImagenPixeles: TArregloPixeles; // Arreglo de pixeles con valores RGB
begin
  // Se crea una imagen vacía en memoria
  Imagen := TFPMemoryImage.Create(0, 0);

  // Selecciona el lector basado en la extensión del archivo
  if LowerCase(ExtractFileExt(NombreArchivo)) = '.jpg' then
    LectorImagen := TFPReaderJPEG.Create
  else if LowerCase(ExtractFileExt(NombreArchivo)) = '.png' then
    LectorImagen := TFPReaderPNG.Create
  else
  begin
    // Se muestra un mensaje si el formato no es compatible y salir
    WriteLn('Formato de archivo no soportado: ', NombreArchivo);
    Exit;
  end;

  // Se Carga la imagen y asignar el tamaño del arreglo según sus dimensiones
  Imagen.LoadFromFile(NombreArchivo, LectorImagen);
  SetLength(ImagenPixeles, Imagen.Width, Imagen.Height);

  // Itera sobre cada fila y columna de la imagen
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      // Se obtiene el color del píxel en la posición actual
      ColorPixel := Imagen.Colors[Columna, Fila];
      ImagenPixeles[Columna, Fila].Rojo := ColorPixel.Red shr 8;
      ImagenPixeles[Columna, Fila].Verde := ColorPixel.Green shr 8;
      ImagenPixeles[Columna, Fila].Azul := ColorPixel.Blue shr 8;
    end;

  // Se libera la memoria utilizada para lector y la imagen
  LectorImagen.Free;
  Imagen.Free;

  // Devuelve el arreglo con valores RGB de cada píxel
  LectorPixeles := ImagenPixeles;
end;

// Min: Calcula el valor mínimo entre dos enteros
function Min(A, B: Integer): Integer;
begin
  if A < B then
    Min := A
  else
    Min := B;
end;

// CalcularRadioCirculo: Calcula el radio del círculo en el centro de la imagen
// Parámetros:
// - Pixeles: Arreglo con valores RGB de la imagen
// Devuelve: El radio del círculo detectado desde el centro
function CalcularRadioCirculo(const Pixeles: TArregloPixeles): Integer;
var
  CentroX, CentroY, Columna, Fila: Integer;
  RadioIzquierdo, RadioDerecho, RadioArriba, RadioAbajo: Integer;
begin
  // Se calcula la posición del centro de la imagen
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;

  // Buscar el primer píxel negro desde el centro hacia la izquierda
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

  // Buscar el primer píxel negro desde el centro hacia la derecha
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

  // Buscar el primer píxel negro desde el centro hacia arriba
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

  // Buscar el primer píxel negro desde el centro hacia abajo
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

  // El radio será el menor de los radios calculados en cada dirección
  CalcularRadioCirculo := Min(Min(RadioIzquierdo, RadioDerecho), Min(RadioArriba, RadioAbajo));
end;

// EsNube: Verifica si un píxel es considerado como nube
// Parámetros:
// - R, G, B: Valores de los componentes RGB del píxel
// Devuelve: Verdadero si el píxel se considera nube, falso en caso contrario
function EsNube(R, G, B: Byte): Boolean;
var
  MaxVal, MinVal: Byte;
  Tono, Saturacion, Brillo: Real;
begin
  // Cálculo de brillo y saturación
  MaxVal := Max(Max(R, G), B);
  MinVal := Min(Min(R, G), B);
  Brillo := MaxVal / 255.0;

  if MaxVal = 0 then
    Saturacion := 0
  else
    Saturacion := 1 - (MinVal / MaxVal);

  // Cálculo del tono (no afecta el criterio final)
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

  // Definición de "nube" basado en brillo y saturación
  EsNube := (Brillo > 0.8) and (Saturacion < 0.2)
            and not ((Tono >= 200) and (Tono <= 220));
end;

// ConvertirBlancoYNegro: Convierte la imagen a blanco y negro y calcula índice de cobertura nubosa
// Parámetros:
// - Pixeles: Arreglo con valores RGB de la imagen
// - Radio: Radio del círculo central donde se detectan las nubes
// Función añadida para contar píxeles totales y de nube, y calcular el índice de cobertura
procedure ConvertirBlancoYNegro(const Pixeles: TArregloPixeles; const Radio: Integer);
var
  CentroX, CentroY, Columna, Fila, TotalPixeles, PixelesNube: Integer;
  Blanco, Negro: TFPColor;
  DistanciaCuadrada: Integer;
  IndiceCoberturaNubosa: Real;
begin
  Blanco.Red := 65535; Blanco.Green := 65535; Blanco.Blue := 65535;
  Negro.Red := 0; Negro.Green := 0; Negro.Blue := 0;
  // Calcula el centro de la imagen
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;
  TotalPixeles := 0;
  PixelesNube := 0;

  // Itera sobre cada píxel para identificar nubes y convertir a blanco y negro
  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      DistanciaCuadrada := Sqr(Columna - CentroX) + Sqr(Fila - CentroY);
      if DistanciaCuadrada <= Sqr(Radio) then
      begin
        Inc(TotalPixeles);
        if EsNube(Pixeles[Columna, Fila].Rojo, Pixeles[Columna, Fila].Verde, Pixeles[Columna, Fila].Azul) then
        begin
          Inc(PixelesNube);
          Pixeles[Columna, Fila].Rojo := Blanco.Red shr 8;
          Pixeles[Columna, Fila].Verde := Blanco.Green shr 8;
          Pixeles[Columna, Fila].Azul := Blanco.Blue shr 8;
        end
        else
        begin
          Pixeles[Columna, Fila].Rojo := Negro.Red shr 8;
          Pixeles[Columna, Fila].Verde := Negro.Green shr 8;
          Pixeles[Columna, Fila].Azul := Negro.Blue shr 8;
        end;
      end;
    end;

    // Calcula índice de cobertura nubosa
  if TotalPixeles > 0 then
    IndiceCoberturaNubosa := (TotalPixeles / PixelesNube) * 100
  else
    IndiceCoberturaNubosa := 0;

  WriteLn('Índice de cobertura nubosa: ', IndiceCoberturaNubosa:0:2, '%');
end;


procedure GuardarImagenRecortada(const Pixeles: TArregloPixeles; const Salida: string);
var
  ImagenNueva: TFPMemoryImage;
  Columna, Fila: Integer;
begin
  ImagenNueva := TFPMemoryImage.Create(Length(Pixeles), Length(Pixeles[0]));
  ImagenNueva.UsePalette := False;

  // Itera sobre cada píxel y asigna sus valores RGB y transparencia
  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      ImagenNueva.Colors[Columna, Fila] := FPColor(
        Pixeles[Columna, Fila].Rojo shl 8,
        Pixeles[Columna, Fila].Verde shl 8,
        Pixeles[Columna, Fila].Azul shl 8,
        ifthen((Pixeles[Columna, Fila].Rojo = 0) and 
               (Pixeles[Columna, Fila].Verde = 0) and 
               (Pixeles[Columna, Fila].Azul = 0), 0, 65535) // Transparente si es negro
      );
    end;

  // Guardar como PNG con transparencia
  ImagenNueva.SaveToFile(Salida, TFPWriterPNG.Create);
  ImagenNueva.Free;
end;

var
  ArchivoImagen: String;
  Pixeles: TArregloPixeles;
  Radio: Integer;
begin
  ArchivoImagen := '../Imagenes/11838.jpg';
  Pixeles := LectorPixeles(ArchivoImagen);
  Radio := CalcularRadioCirculo(Pixeles);
  ConvertirBlancoYNegro(Pixeles, Radio);
  GuardarImagenRecortada(Pixeles, '../Imagenes/11838_final.png');
end.  