public class Student extends Person implements Questionable {
    int rollNum;

    public Student(String fst, String lst, int rNum) {
        super(fst, lst);
        rollNum = rNum;
    }

    public void say(String text) { // when I don't want the same behaviour as my parent, I override
        super.say("Excuse me, " + text);
    }

    public void question() {
        System.out.println("Student's question: meh meh");
    }
}
