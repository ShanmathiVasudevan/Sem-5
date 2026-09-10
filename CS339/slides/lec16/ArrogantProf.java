public class ArrogantProf extends Professor {
    public ArrogantProf(String fst, String lst) {
        super(fst, "Snape");
    }

    public void say(String text) {
        super.say(text + ", stupid.");
    }
}
