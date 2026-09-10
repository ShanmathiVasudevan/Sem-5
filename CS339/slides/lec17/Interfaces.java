// Interfaces define capabilities. Abstract classes enforce IS-A relations

interface Drawable {
    void draw();
}

abstract class Shape {
    abstract double area(); // without the abstract word in this function decl., we would need to define this function here itself
}

class Circle extends Shape implements Drawable {
    double r;
    Circle(double r) {
        this.r = r;
    }
    public void draw() {
        System.out.println("Drawing Circle with radius " + r);
    }
    public double area() {
        return Math.PI * r * r; // constants in Java are declared as 
                                // final int FOO = 2; (usually in CAPITAL letters)
                                // this constant PI is declared in class Math
    }
}

class Rectangle extends Shape implements Drawable {
    int width, height;
    Rectangle(int w, int h) {
        width = w;
        height = h;
    }
    public void draw() { // throws error when I don't make it public
                         // error: draw() in Rectangle cannot implement draw() in Drawable
                         // void draw() {
                         // ^
                         // attempting to assign weaker access privileges; was public
        System.out.println("Drawing Rectangle with width " + width + " and height " + height);
    }
    public double area() { // doesn't throw error even when I don't make it public
        return width * height;
    }
}
// why do we not have draw() also in the abstract class, why have it as an interface?
// think about extensibility! there can be things we want to draw but which are not shapes
// eg: UIElement
// there can also be shapes which we don't want to draw! :)
enum Color { RED, BLUE, GREEN; } // why use enum? readability, extensibility, efficiency of memory (can potentially use less number of bits (here, 2) than a normal int (4 bytes))
abstract class UIElement {
    Color color;
    UIElement() { // a note about constructors - super() constructor is always called first
                  // who is a parent class for this UIElement though? java.lang.Object - the only class in Java with no parent
        color = Color.RED;
    }
    abstract void click();
}
class Button extends UIElement implements Drawable {
    // no constructor here, so it just calls the super constructor
    public void draw() {
        System.out.println("Drawing Button with color " + color);
    }
    public void click() {
        System.out.println("Button clicked");
    }
}

public class Interfaces {
    public static void main(String[] args) {
        Drawable[] items = new Drawable[3]; // an array of pointers - it can't allocate memory yet
        items[0] = new Circle(5); // allocates memory required for a Circle, then items[0] points to this 
        items[1] = new Rectangle(3, 4);
        items[2] = new Button();

        for (Drawable d : items) {
            d.draw(); // this is called runtime polymorphism (OO polymorphism) which is based on subtypes (like Monkey is a subtype of Animal), 
                      // there is something called compile time polymorphism (generic polymorphism) which uses generics (List<T> etc)
        }

        Shape[] shapes = new Shape[2];
        shapes[0] = new Circle(4);
        shapes[1] = new Rectangle(5,3);
        double totalArea = 0;
        for (Shape s : shapes){
            totalArea += s.area();
        }
        System.out.println("Total area is " + totalArea);
    }
}
