program LectorDePixeles;

uses
  SysUtils, Math, FPImage, FPReadJPEG, FPReadPNG, FPWritePNG, Classes;

type
// Tipo de arreglo para almacenar los valores RGB de cada píxel de una imagen
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

// LectorPixeles: Lee una imagen y devuelve un arreglo con valores RGB de cada píxel.
// Parámetros:
// - NombreArchivo: Ruta y nombre del archivo de la imagen a leer.
// Devuelve: Arreglo de píxeles con componentes RGB.
function LectorPixeles(const NombreArchivo: String): TArregloPixeles;
var
  Imagen: TFPMemoryImage; //Objeto para cargar una imagen en la memoria
  LectorImagen: TFPCustomImageReader; //Lector de imagen JPG o PNG
  Columna, Fila: Integer; //Variables para iterar sobre filas y columnas
  ColorPixel: TFPColor; //Variable para almacenar el color de cada pixel
  ImagenPixeles: TArregloPixeles; //Arreglo de pixeles con valores RGB
begin
// Se crea una imagen vacía en memoria
  Imagen := TFPMemoryImage.Create(0, 0);

  // Selecciona el lector basado en la extensión del archivo
  if (LowerCase(ExtractFileExt(NombreArchivo)) = '.jpg') or 
  (LowerCase(ExtractFileExt(NombreArchivo)) = '.jpeg') then
    LectorImagen := TFPReaderJPEG.Create
  else if LowerCase(ExtractFileExt(NombreArchivo)) = '.png' then
  begin
    LectorImagen := TFPReaderPNG.Create
  end
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

function CalcularRadioCirculo(const Pixeles: TArregloPixeles): Integer;
var
  CentroX, CentroY, Columna: Integer;
  Radio: Integer;
begin
  // Se calcula la posición del centro de la imagen
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;
  Radio := 0;

  // Se busca el primer píxel no negro desde el centro hacia la izquierda
  for Columna := CentroX downto 0 do
  begin
    if (Pixeles[Columna, CentroY].Rojo > 50) or 
       (Pixeles[Columna, CentroY].Verde > 50) or 
       (Pixeles[Columna, CentroY].Azul > 50) then
    begin
      Radio := CentroX - Columna;
      Break;
    end;
  end;

  // Devuelve el radio encontrado
  CalcularRadioCirculo := Radio;
end;

procedure RecortarCirculo(var Pixeles: TArregloPixeles; Radio: Integer);
var
  CentroX, CentroY, Columna, Fila: Integer;
  Distancia: Double;
begin
  // Se calcula la posición del centro de la imagen
  CentroX := Length(Pixeles) div 2;
  CentroY := Length(Pixeles[0]) div 2;

  // Itera sobre cada píxel y calcula su distancia al centro
  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      Distancia := Sqrt(Sqr(Columna - CentroX) + Sqr(Fila - CentroY));
      if Distancia > Radio then
      begin
        // Hace el píxel completamente transparente si está fuera del círculo
        Pixeles[Columna, Fila].Rojo := 0;
        Pixeles[Columna, Fila].Verde := 0;
        Pixeles[Columna, Fila].Azul := 0;
      end;
    end;
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
  RecortarCirculo(Pixeles, Radio);
  GuardarImagenRecortada(Pixeles, '../Imagenes/11838_recortada.png');
end.
