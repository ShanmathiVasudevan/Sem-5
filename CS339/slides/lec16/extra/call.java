// call.java file from 2.18.AA.26

class toCall{

    static int x = 5;

    {
        System.out.println("Hello from initilizer 1");
    }

    toCall(){
        System.out.println("Hello from constructor 1");
    }

    toCall(int x){
        System.out.println("Hello from constructor 2");
    }

    {
        System.out.println("Hello from initilizer 2");
    }

    static{
        System.out.println("Hello from static initilizer");
    }
}

// Version 1 -> toCall object never created.

// public class call{
//     public static void main(String[] args){
//         System.out.println("Hello from main");
//     }
// }

/* Output 1 

└─$ java call 
Hello from main

*/

// Reasoning - toCall class was never loaded into the memory. Thus, static initializer was never executed.


// Version 2 -> we try to print toCall.x. 

// public class call{
//     public static void main(String[] args){
//         System.out.println("Hello from main");
//         System.out.println(toCall.x);
//     }
// }

// Output 2

/* 
└─$ java call 
Hello from main
Hello from static initilizer
5
*/

// Reasoning - toCall class was loaded into the memory. Thus, static initializer was executed. However, no object of toCall was created. Thus, instance initializers and constructors were never executed.

// Version 3 -> we try to create an object of toCall.

// public class call{
//     public static void main(String[] args){
//         System.out.println("Hello from main");
//         toCall t = new toCall();
//         System.out.println(t.x);
//     }
// }

// Output 3

/* 
└─$ java call 
Hello from main
Hello from static initilizer
Hello from initilizer 1
Hello from initilizer 2
Hello from constructor 1
5
*/

// Reasoning - toCall class was loaded into the memory. Thus, static initializer was executed. An object of toCall was created. Thus, instance initializers and constructors were executed. Note that initializers are called before the constructor. They are called in the order they are defined in the class. 


// Version 4 -> multiple objects of toCall are created.

// public class call{
//     public static void main(String[] args){
//         System.out.println("Hello from main");
//         toCall t1 = new toCall();
//         t1.x++;
//         toCall t2 = new toCall(6);
//         t2.x++;
//         toCall t3 = new toCall();
//         System.out.println(t3.x);
//     }
// }

// Output 4

/*
└─$ java call 
Hello from main
Hello from static initilizer
Hello from initilizer 1
Hello from initilizer 2
Hello from constructor 1
Hello from initilizer 1
Hello from initilizer 2
Hello from constructor 2
Hello from initilizer 1
Hello from initilizer 2
Hello from constructor 1
7
*/

// Reasoning - Static initializers are only called once when class is loaded into memory while instance initializers and constructors are called every time an object is created. Note that the static variable x is shared across all objects of the class toCall. Thus, when we increment x in t1 and t2, it affects the value of x in t3 as well. Hehe, we learnt from static variables also from here :).


// Version 5 -> we try to create objects as fields of the call class. 

public class call{
    toCall t = new toCall();

    public static void main(String[] args){
        System.out.println("Hello from main");
        // call c = new call();
        // System.out.println(c.t);
    }
}

// Output 5

/*
└─$ java call
Hello from main
*/

// Reasoning - I am guessing that jvm will be calling the main (static function), like the way we accessed static variable in version 2, so non-static variable in = new toCall() will not be called. Thus, the class toCall is never loaded into memory and even the static initializers are never executed.

// Version 6 -> we try to create objects as "static" fields of the call class

// public class call{
//     static toCall t;

//     public static void main(String[] args){
//         System.out.println("Hello from main");
//         System.out.println(t);
//     }
// }

// Output 6

/*
└─$ java call 
Hello from main
*/

// Reasoning - Woah, new for me too. I was expecting the static initializer of toCall to be executed. But it was not. The line 149 - static toCall in; is just a declaration of a static variable and apparently doesn't load the class into memory. That leads me to trying version 7, just printing the value of t.

// Version 7 -> we try to print the value of the static field t of the call class

// public class call{
//     static toCall t;

//     public static void main(String[] args){
//         System.out.println("Hello from main");
//         System.out.println(t);
//     }
// }

// Output 7

/*
└─$ java call 
Hello from main
null
*/

// Reasoning - As expected, the value of t is null. Explaining why the toCall class was never laoded.

// Version 8 -> we try to create objects as "static" fields of the call class and initialize them.

// public class call{
//     static toCall t = new toCall();

//     public static void main(String[] args){
//         System.out.println("Hello from main");
//     }
// }

// Output 8

/*
└─$ java call 
Hello from static initilizer
Hello from initilizer 1
Hello from initilizer 2
Hello from constructor 1
Hello from main
*/

// I have tried to handle all the possible scenarios I could think of. If you have any other scenario in mind, please let me know and I will try to handle that as well.