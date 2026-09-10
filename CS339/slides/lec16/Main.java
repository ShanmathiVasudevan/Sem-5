public class Main {
    public static void main(String[] args) {
        Person p1 = new Professor("Albus", "Dumbledore");
        // Person is an abstract class, so we can't say new Person(...)
        // But it can point to anything under it in the ISA hierarchy
        // What is accessible? Parent fields? Parent methods?

        // Note: Generally, we want to use the most general type. 
        // eg? suppose you have a Numberable interface (with an add ability), and you have int and float implementing this, now you can add "Numberable"s with each other



        ArrogantProf p2 = new ArrogantProf("Severus", "Snape"); // what if this was Person p2?

        Student s = new Student("Hermione", "Granger", 101);

        Course c = new Course(420, p2); // if p2 was a Person, this wouldn't work! Because it is a Person, not a Professor like the Course(...) wants
                                        // it can't just assume this is an ArrogantProf. Why?
                                        // eg: if (bloop_dee_bloop){
                                        //       p2 = new ArrogantProf(...);
                                        //     } else {
                                        //       p2 = new Student(...);
                                        //     }
                                        // Compiler won't know till runtime what value bloop_dee_bloop has. So it takes the type of p2 as it can see, which is Person
        c.addStudent(s);
        c.start();
    }
}
