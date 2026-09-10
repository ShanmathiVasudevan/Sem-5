public class ObjectSemantics {
    public static void main(String[] args) {
        Animal p1;
        p1 = new Animal();
        System.out.println(p1.x + " " + p1.y); // 10 10 - normal, expected
        // System.out.println(((Monkey)p1).z); Exception in thread "main" java.lang.ClassCastException: class Animal cannot be cast to class Monkey (Animal and Monkey are in unnamed module of loader 'app')
        //                                     at ObjectSemantics.main(ObjectSemantics.java:6)
        // This is a runtime error in Java, which is called exception.
        // Compiler got fooled by the type casting, but in runtime it got caught.
        // We can easily fool the compiler in static casting. Java doesn't have dynamic casting.
        Animal p2;
        p2 = new Monkey();
        System.out.println(p2.x + " " + p2.y); // 20 10
        // System.out.println(p2.x + " " + p2.y + " " + p2.z); error: cannot find symbol
        //                                                    symbol: variable z
        //                                                    location: variable p2 of type Animal
        System.out.println(p2.x + " " + p2.y + " " + ((Monkey)p2).z); // 20 10 20
        System.out.println(p2.x + " " + ((Monkey)p2).y + " " + ((Monkey)p2).z); // 20 20 20
        System.out.println(((Monkey)p2).x + " " + ((Monkey)p2).y + " " + ((Monkey)p2).z); // 20 20 20

        p2.sound(); // Animal's sound: 10
        p2.tail(); // Monkey's tail
        ((Animal) p2).tail(); // Monkey's tail



        Monkey p3;
        // p3 = new Animal(); error: incompatible types: Animal cannot be converted to Monkey
        p3 = new Monkey();
        System.out.println(p3.x + " " + p3.y + " " + p3.z); // 20 20 20
        System.out.println(p3.x + " " + ((Animal)p3).y + " " + p3.z); // 20 10 20
        System.out.println(((Animal)p3).x + " " + ((Animal)p3).y + " " + p3.z); // 20 10 20
        p3.sound(); // Animal's sound: 10
        p3.tail(); // Monkey's tail
        ((Animal) p3).tail(); // Monkey's tail

    }
}

class Animal {
    int x;
    int y;
    Animal() {
        x = y = 10;
    }
    void sound() {
        System.out.println("Animal's sound: " + y); // this y is Animal's y
    }
    void tail() {
        System.out.println("Animal's tail");
    }
}
class Monkey extends Animal {
    int y;
    int z;
    Monkey() {
        // super();
        x = y = z = 20;
    }
    void tail() {
        System.out.println("Monkey's tail");
    }
}
