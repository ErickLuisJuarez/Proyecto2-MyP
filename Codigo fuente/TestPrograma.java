public class TestPrograma {
    
    /**
     * Prueba de la clase Pixel.
     * Crea una instancia de Pixel con valores RGB específicos y muestra los valores de sus componentes de color.
     */
    public static void testPixel(){
        System.out.println("Test de la clase Pixel:");
        Pixel pixel = new Pixel(255, 100, 50);
        System.out.println("Rojo: " + pixel.rojo);
        System.out.println("Verde: " + pixel.verde);
        System.out.println("Azul: " + pixel.azul);
    }

    /**
     * Prueba del lector de píxeles desde un archivo de imagen.
     * Muestra los valores RGB del primer píxel en la matriz obtenida.
     * @param archivo Ruta del archivo de imagen JPEG a procesar.
     */
    public static void testLectorPixeles(String archivo) {
        System.out.println("\nTest de lectorPixeles:");
        try {
            Pixel[][] pixeles = Programa.lectorPixeles(archivo);
            System.out.println("Primer pixel (0,0):");
            System.out.println("Rojo: " + pixeles[0][0].rojo);
            System.out.println("Verde: " + pixeles[0][0].verde);
            System.out.println("Azul: " + pixeles[0][0].azul);
        } catch (Exception e) {
            System.err.println("Error al leer los pixeles: " + e.getMessage());
        }
    }

     /**
     * Prueba del cálculo del radio del círculo en la imagen.
     * Muestra el radio calculado a partir de la matriz de píxeles.
     * @param archivo Ruta del archivo de imagen JPEG a procesar.
     */
    public static void testCalcularRadioCirculo(String archivo) {
        System.out.println("\nTest de calcularRadioCirculo:");
        try {
            Pixel[][] pixeles = Programa.lectorPixeles(archivo);
            int radio = Programa.calcularRadioCirculo(pixeles);
            System.out.println("Radio calculado: " + radio);
        } catch (Exception e) {
            System.err.println("Error al calcular el radio: " + e.getMessage());
        }
    }

    /**
     * Prueba de la conversión de la imagen a blanco y negro.
     * Muestra los valores RGB del primer píxel tras la conversión.
     * @param archivo Ruta del archivo de imagen JPEG a procesar.
     */
    public static void testConvertirBlancoYNegro(String archivo) {
        System.out.println("\nTest de convertirBlancoYNegro:");
        try {
            Pixel[][] pixeles = Programa.lectorPixeles(archivo);
            int radio = Programa.calcularRadioCirculo(pixeles);
            Pixel[][] pixelesBlancoYNegro = Programa.convertirBlancoYNegro(pixeles, radio);
            System.out.println("Pixel en blanco y negro (0,0):");
            System.out.println("Rojo: " + pixelesBlancoYNegro[0][0].rojo);
            System.out.println("Verde: " + pixelesBlancoYNegro[0][0].verde);
            System.out.println("Azul: " + pixelesBlancoYNegro[0][0].azul);
        } catch (Exception e) {
            System.err.println("Error al convertir la imagen a blanco y negro: " + e.getMessage());
        }
    }

    /**
     * Prueba del cálculo del índice de cobertura nubosa (CCI).
     * Muestra el índice calculado en porcentaje.
     * @param archivo Ruta del archivo de imagen JPEG a procesar.
     */
    public static void testCalcularIndice(String archivo) {
        System.out.println("\nTest de calcularIndice:");
        try {
            Pixel[][] pixeles = Programa.lectorPixeles(archivo);
            int radio = Programa.calcularRadioCirculo(pixeles);
            Pixel[][] pixelesByN = Programa.convertirBlancoYNegro(pixeles, radio);
            double indice = Programa.calcularIndice(pixelesByN, radio);
            System.out.println("Índice de cobertura nubosa: " + indice + "%");
        } catch (Exception e) {
            System.err.println("Error al calcular el índice: " + e.getMessage());
        }
    }
	
	/**
     * Método principal para ejecutar las pruebas de la clase TestPrograma.
     * Define la ruta de la imagen de prueba y ejecuta todas las pruebas.
     * @param args Argumentos de línea de comandos (no se usan en este programa).
     */
    public static void main(String[] args){
		String archivo = "../Imagenes/11838.jpg";
		testPixel();
		testLectorPixeles(archivo);
		testCalcularRadioCirculo(archivo);
		testConvertirBlancoYNegro(archivo);
		testCalcularIndice(archivo);
	}
}