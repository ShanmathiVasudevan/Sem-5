public class Professor extends Person implements Questionable {
    public Professor(String fst, String lst) {
        super("Prof. " + fst, lst);
    }

    public void lecture(String text) {
        say("Therefore, " + text);
    }

    public void question() { // we need to override question() of the interface Questionable
        System.out.println("Professor's question: blah blah");
    }

    public void answer() {
        System.out.println("Let's discuss this offline.");
    }
}
