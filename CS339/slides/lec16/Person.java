public abstract class Person { // Person cannot be instantiated as it is an abstract class
    String firstName;
    String lastName;

    public Person(String fst, String lst) {
        firstName = fst;
        lastName = lst;
    }

    public String whoAreYou() {
        return firstName + " " + lastName; // + here is string concatenation
    }

    public void say(String text) {
        System.out.println(text);
    }

}

// every non-primitive variable is a pointer in Java. primitive variables include int and boolean