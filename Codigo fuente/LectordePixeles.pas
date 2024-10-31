program LectorDePixeles;

uses
  SysUtils, FPImage, FPReadJPEG, FPReadPNG, FPWritePNG, Classes;

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
//Se crea una imagen vacía en memoria
  Imagen := TFPMemoryImage.Create(0, 0);

  //Selecciona el lector basado en la extensión del archivo
  if LowerCase(ExtractFileExt(NombreArchivo)) = '.jpg' then
    LectorImagen := TFPReaderJPEG.Create
  else if LowerCase(ExtractFileExt(NombreArchivo)) = '.png' then
    LectorImagen := TFPReaderPNG.Create
  else
  begin
  //Se muestra un mensaje si el formato no es compatible y salir
    WriteLn('Formato de archivo no soportado: ', NombreArchivo);
    Exit;
  end;

  // Se Carga la imagen y asignar el tamaño del arreglo según sus dimensiones
  Imagen.LoadFromFile(NombreArchivo, LectorImagen);
  SetLength(ImagenPixeles, Imagen.Width, Imagen.Height);

  //Itera sobre cada fila y columna de la imagen
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
    //Se obtiene el color del píxel en la posición actual
      ColorPixel := Imagen.Colors[Columna, Fila];
      ImagenPixeles[Columna, Fila].Rojo := ColorPixel.Red shr 8;
      ImagenPixeles[Columna, Fila].Verde := ColorPixel.Green shr 8;
      ImagenPixeles[Columna, Fila].Azul := ColorPixel.Blue shr 8;
    end;

   //Se libera la memoria utilizada para lector y la imagen
  LectorImagen.Free;
  Imagen.Free;

  //Devuelve el arreglo con valores RGB de cada píxel
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
