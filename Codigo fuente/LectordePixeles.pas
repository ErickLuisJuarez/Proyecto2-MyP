program LectorDePixeles;

uses
  SysUtils, FPImage, FPReadJPEG, FPReadPNG, Classes;

type
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

function LectorPixeles(const NombreArchivo: String): TArregloPixeles;
var
  Imagen: TFPMemoryImage;
  LectorImagen: TFPCustomImageReader;
  Columna, Fila: Integer;
  ColorPixel: TFPColor;
  ImagenPixeles: TArregloPixeles;
begin
  // Inicializar la imagen
  Imagen := TFPMemoryImage.Create(0, 0);

  // Seleccionar el lector adecuado según la extensión
  if LowerCase(ExtractFileExt(NombreArchivo)) = '.jpg' then
    LectorImagen := TFPReaderJPEG.Create
  else if LowerCase(ExtractFileExt(NombreArchivo)) = '.png' then
    LectorImagen := TFPReaderPNG.Create
  else
  begin
    WriteLn('Formato de archivo no soportado: ', NombreArchivo);
    Exit;
  end;

  // Cargar la imagen
  Imagen.LoadFromFile(NombreArchivo, LectorImagen);
  SetLength(ImagenPixeles, Imagen.Width, Imagen.Height);

  // Iterar sobre los píxeles y extraer valores RGB
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      ColorPixel := Imagen.Colors[Columna, Fila];
      ImagenPixeles[Columna, Fila].Rojo := ColorPixel.Red shr 8;
      ImagenPixeles[Columna, Fila].Verde := ColorPixel.Green shr 8;
      ImagenPixeles[Columna, Fila].Azul := ColorPixel.Blue shr 8;
    end;

  // Liberar recursos
  LectorImagen.Free;
  Imagen.Free;

  // Devolver el arreglo con los píxeles
  LectorPixeles := ImagenPixeles;
end;

var
  ArchivosImagen: array[1..4] of String;
  ImagenPixeles: TArregloPixeles;
  I: Integer;

begin
  // Lista de archivos de imagen
  ArchivosImagen[1] := '../Imagenes/11838.jpg';
  ArchivosImagen[2] := '../Imagenes/11838-clean.png';
  ArchivosImagen[3] := '../Imagenes/11838-convolved.png';
  ArchivosImagen[4] := '../Imagenes/11838-filter.png';

  for I := 1 to 4 do
  begin
    // Llamada a la función LectorPixeles
    ImagenPixeles := LectorPixeles(ArchivosImagen[I]);
    
    WriteLn('La imagen ', ArchivosImagen[I], ' ha sido cargada y los valores RGB han sido almacenados.');
  end;
end.
