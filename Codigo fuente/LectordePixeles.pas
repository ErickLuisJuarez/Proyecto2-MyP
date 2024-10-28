program LectorDePixeles;

uses
  SysUtils, FPImage, FPReadJPEG, FPReadPNG, FPWritePNG, Classes;

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

procedure QuitarFondo(const NombreArchivo: string; const Salida: string);
var
  ImagenNueva: TFPMemoryImage;
  Columna, Fila: Integer;
  Pixeles: TArregloPixeles;
begin
  Pixeles := LectorPixeles(NombreArchivo);
  ImagenNueva := TFPMemoryImage.Create(Length(Pixeles), Length(Pixeles[0]));
  ImagenNueva.UsePalette := False;

  for Fila := 0 to High(Pixeles[0]) do
    for Columna := 0 to High(Pixeles) do
    begin
      if (Pixeles[Columna, Fila].Rojo < 50) and
         (Pixeles[Columna, Fila].Verde < 50) and
         (Pixeles[Columna, Fila].Azul < 50) then
      begin
        // Hacer el píxel completamente transparente si es negro
        ImagenNueva.Colors[Columna, Fila] := FPColor(0, 0, 0, 0);
      end
      else
      begin
        ImagenNueva.Colors[Columna, Fila] := FPColor(
          Pixeles[Columna, Fila].Rojo shl 8,
          Pixeles[Columna, Fila].Verde shl 8,
          Pixeles[Columna, Fila].Azul shl 8,
          65535 // Opacidad total para los píxeles que no son negros
        );
      end;
    end;

  // Guardar como PNG con transparencia
  ImagenNueva.SaveToFile(Salida, TFPWriterPNG.Create);
  ImagenNueva.Free;
end;

var
  ArchivoImagen: String;

begin
  ArchivoImagen := '../Imagenes/11838.jpg';
  QuitarFondo(ArchivoImagen, '../Imagenes/11838_sin_fondo.png');
  WriteLn('La imagen ', ArchivoImagen, ' ha sido procesada como 11838_sin_fondo.png');
end.
