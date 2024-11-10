import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;
import java.util.Scanner;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Ejecutable {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Por favor, ingresa el nombre del archivo: ");
        String ruta = System.getProperty("user.dir");
        String nombreArchivo = scanner.nextLine();
        
        // Crear la ruta original con "../"
        Path rutaCompleta = Paths.get(ruta, "../Imagenes", nombreArchivo);
        
        // Normalizar la ruta para simplificarla
        Path rutaNormalizada = rutaCompleta.normalize();
        
        System.out.println("La ruta del archivo es: " + rutaNormalizada);
        try {
            Pixel[][] pixeles = Programa.lectorPixeles(rutaNormalizada.toString());
            int radio = Programa.calcularRadioCirculo(pixeles);
            Pixel[][] pixelesByN = Programa.convertirBlancoYNegro(pixeles, radio);
      
            String salida = "imagen_salida.png";
            Programa.guardarImagenRecortada(pixelesByN, salida);
      
            double indice = Programa.calcularIndice(pixelesByN, radio);
            System.out.println("Índice de cobertura nubosa: " + indice + "%");
      
          } catch (Exception e) {
            System.err.println("Error al procesar la imagen. Verifica que la ruta sea correcta.");
            e.printStackTrace();
          } finally {
            scanner.close();
          }
    }
    
}

