import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;

public class Ejecutable {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Por favor, ingresa el nombre del archivo seguido de la bandera (opcional): ");
        
        // Leer la línea completa y dividirla en partes
        String input = scanner.nextLine().trim();
        String[] partes = input.split("\\s+");  // Divide en base a espacios

        String nombreArchivo = partes[0];
        String bandera = (partes.length > 1) ? partes[1] : "";

        String ruta = System.getProperty("user.dir");
        Path rutaCompleta = Paths.get(ruta, "../Imagenes", nombreArchivo);
        Path rutaNormalizada = rutaCompleta.normalize();

        System.out.println("La ruta del archivo es: " + rutaNormalizada);
        
        try { 
            Pixel[][] pixeles = Programa.lectorPixeles(rutaNormalizada.toString());
            int radio = Programa.calcularRadioCirculo(pixeles);
            Pixel[][] pixelesByN = Programa.convertirBlancoYNegro(pixeles, radio);
            double indice = Programa.calcularIndice(pixelesByN, radio);
            
            System.out.println("Índice de cobertura nubosa: " + indice + "%");

            if (bandera.equalsIgnoreCase("S")) {
                String salida = "imagen_salida.png";
                Programa.guardarImagenRecortada(pixelesByN, salida);
            }
            
        } catch (Exception e) {
            System.err.println("Error al procesar la imagen. Verifica que la ruta sea correcta.");
            e.printStackTrace();
        } finally {
            scanner.close();
        }
    }
}
