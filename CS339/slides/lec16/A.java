// The main method is in a class of the same name as the file
public class A{
	public static void main(String[] args){
		System.out.println("Hello");
		B b = new B();
		b.foo();
	}
	//B b  = new B();
	//b.foo(); writing here gives the error : <identifier> expected
}
//a = "bloop";
//uncommenting the above 1 line gives the below error:
//error: class, interface, annotation type, enum, record, method or field expected
//a = "bloop";
//^
//1 error


//public void foo(){
//	System.out.println("outside!");
//}
//uncommenting the above three lines gives the below error:
//error: non-static variable this cannot be referenced from a static context
//               B b = new B();
//                      ^
//error: compact source file does not have main method in the form of void main() or void main(String[] args)
//public class A{
//^
//2 errors
class B{ // if you write public class B, it expects that the class B should be in B.java
	public void foo(){
		System.out.println("B");
	}
}
// javac A.java gives A.class
// If A.java contains another class say B, B.class will also be produced on running the above
// javap -c A visualises the bytecode
// java A executes the program and outputs
// Hello
//
// Below is the output of javap -c A
// Compiled from "A.java"
// public class A {
//  public A();
//    Code:
//         0: aload_0
//         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
//         4: return
//
//  public static void main(java.lang.String[]);
//    Code:
//         0: getstatic     #7                  // Field java/lang/System.out:Ljava/io/PrintStream;
//         3: ldc           #13                 // String Hello
//         5: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
//         8: return
//}
//
