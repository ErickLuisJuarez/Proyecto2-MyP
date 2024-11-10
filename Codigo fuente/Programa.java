import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

public class Programa {

  public static class Pixel {
    public int rojo, verde, azul;

    public Pixel(int rojo, int verde, int azul) {
      this.rojo = rojo;
      this.verde = verde;
      this.azul = azul;
    }
  }

  public static Pixel[][] lectorPixeles(String nombreArchivo) throws Exception {
    BufferedImage imagen = ImageIO.read(new File(nombreArchivo));
    int width = imagen.getWidth();
    int height = imagen.getHeight();
    Pixel[][] imagenPixeles = new Pixel[width][height];

    for (int fila = 0; fila < height; fila++) {
      for (int columna = 0; columna < width; columna++) {
        Color color = new Color(imagen.getRGB(columna, fila));
        imagenPixeles[columna][fila] = new Pixel(color.getRed(), color.getGreen(), color.getBlue());
      }
    }

    return imagenPixeles;
  }

  public static int calcularRadioCirculo(Pixel[][] pixeles) {
    int centroX = pixeles.length / 2;
    int centroY = pixeles[0].length / 2;

    int radioIzquierdo = centroX;
    for (int columna = centroX; columna >= 0; columna--) {
      if (pixeles[columna][centroY].rojo < 50 && pixeles[columna][centroY].verde < 50 && pixeles[columna][centroY].azul < 50) {
        radioIzquierdo = centroX - columna;
        break;
      }
    }

    int radioDerecho = pixeles.length - centroX;
    for (int columna = centroX; columna < pixeles.length; columna++) {
      if (pixeles[columna][centroY].rojo < 50 && pixeles[columna][centroY].verde < 50 && pixeles[columna][centroY].azul < 50) {
        radioDerecho = columna - centroX;
        break;
      }
    }

    int radioArriba = centroY;
    for (int fila = centroY; fila >= 0; fila--) {
      if (pixeles[centroX][fila].rojo < 50 && pixeles[centroX][fila].verde < 50 && pixeles[centroX][fila].azul < 50) {
        radioArriba = centroY - fila;
        break;
      }
    }

    int radioAbajo = pixeles[0].length - centroY;
    for (int fila = centroY; fila < pixeles[0].length; fila++) {
      if (pixeles[centroX][fila].rojo < 50 && pixeles[centroX][fila].verde < 50 && pixeles[centroX][fila].azul < 50) {
        radioAbajo = fila - centroY;
        break;
      }
    }

    return Math.min(Math.min(radioIzquierdo, radioDerecho), Math.min(radioArriba, radioAbajo));
  }

  public static boolean esNube(int r, int g, int b) {
    int maxVal = Math.max(Math.max(r, g), b);
    int minVal = Math.min(Math.min(r, g), b);
    double brillo = maxVal / 255.0;

    double saturacion;
    if (maxVal == 0) {
      saturacion = 0;
    } else {
      saturacion = 1 - (minVal / (double) maxVal);
    }

    double tono;
    if (maxVal == minVal) {
      tono = 0;
    } else if (maxVal == r) {
      tono = 60 * (0 + (g - b) / (double) (maxVal - minVal));
    } else if (maxVal == g) {
      tono = 60 * (2 + (b - r) / (double) (maxVal - minVal));
    } else {
      tono = 60 * (4 + (r - g) / (double) (maxVal - minVal));
    }

    if (tono < 0) {
      tono += 360;
    }

    return (brillo > 0.8) && (saturacion < 0.2) && !(tono >= 200 && tono <= 220);
  }

  public static Pixel[][] convertirBlancoYNegro(Pixel[][] pixeles, int radio) {
    int centroX = pixeles.length / 2;
    int centroY = pixeles[0].length / 2;
    Pixel[][] pixelesByN = new Pixel[pixeles.length][pixeles[0].length];

    for (int fila = 0; fila < pixeles[0].length; fila++) {
      for (int columna = 0; columna < pixeles.length; columna++) {
        int distanciaCuadrada = (columna - centroX) * (columna - centroX) + (fila - centroY) * (fila - centroY);
        if (distanciaCuadrada <= radio * radio) {
          if (esNube(pixeles[columna][fila].rojo, pixeles[columna][fila].verde, pixeles[columna][fila].azul)) {
            pixelesByN[columna][fila] = new Pixel(255, 255, 255);
          } else {
            pixelesByN[columna][fila] = new Pixel(0, 0, 0);
          }
        }
      }
    }

    return pixelesByN;
  }

  public static void guardarImagenRecortada(Pixel[][] pixeles, String salida) throws Exception {
    BufferedImage imagenNueva = new BufferedImage(pixeles.length, pixeles[0].length, BufferedImage.TYPE_INT_RGB);

    for (int fila = 0; fila < pixeles[0].length; fila++) {
      for (int columna = 0; columna < pixeles.length; columna++) {
        Color color = new Color(pixeles[columna][fila].rojo, pixeles[columna][fila].verde, pixeles[columna][fila].azul);
        imagenNueva.setRGB(columna, fila, color.getRGB());
      }
    }

    ImageIO.write(imagenNueva, "png", new File(salida));
  }

  public static double calcularIndice(Pixel[][] pixeles, int radio) {
    int centroX = pixeles.length / 2;
    int centroY = pixeles[0].length / 2;
    int totalPixeles = 0;
    int pixelesNube = 0;

    for (int fila = 0; fila < pixeles[0].length; fila++) {
      for (int columna = 0; columna < pixeles.length; columna++) {
        int distanciaCuadrada = (columna - centroX) * (columna - centroX) + (fila - centroY) * (fila - centroY);
        if (distanciaCuadrada <= radio * radio) {
          totalPixeles++;
          if (pixeles[columna][fila].rojo == 255 && pixeles[columna][fila].verde == 255 && pixeles[columna][fila].azul == 255) {
            pixelesNube++;
          }
        }
      }
    }

    return (pixelesNube / (double) totalPixeles) * 100;
  }
}