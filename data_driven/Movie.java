//Front Page of Movies DataBase
//complete
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Stream;

public class Movie {
    static Connection conn = null;
    static Scanner sc;
    static Statement stmt = null;
    static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final String DB_URL = "jdbc:mysql://localhost/project";

    static final String USER = "root";
    static final String PASS = "root";

    public static void main(String[] args) {

        sc = new Scanner(System.in);
        try{
            Class.forName("com.mysql.jdbc.Driver");
            System.out.println("Connecting to database...");
            conn = DriverManager.getConnection(DB_URL,USER,PASS);
            stmt = conn.createStatement();
//            printMainScreen();
            inputMainChoice();
            stmt.close();
            conn.close();
        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e){
            //Handle errors for Class.forName
            e.printStackTrace();
        }finally{
            //finally block used to close resources
            try{
                if(stmt!=null)
                    stmt.close();
            }catch(SQLException se2){
            }// nothing we can do
            try{
                if(conn!=null)
                    conn.close();
            }catch(SQLException se){
                se.printStackTrace();
            }//end finally try
        }//end try
        System.out.println("GoodBye,Have a Nice Day!");
    }

    public static void printMainScreen(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome to DVD RENTAL STORE                                *");
        System.out.println("***********************************************************************************");
        System.out.println("*\t(1) Press 1 to LOGIN                                                          *");
        System.out.println("*\t(2) Press 2 to SIGNUP                                                         *");
        System.out.println("*\t(3) Press 3 to enter as INVESTOR                                              *");
        System.out.println("*\t(4) Press 4 to enter as EMPLOYEE                                              *");
        System.out.println("*\t(5) Press 5 to enter as ADMIN                                                 *");
        System.out.println("*\t(0) Press 0 to EXIT                                                           *");
        System.out.println("***********************************************************************************");
        System.out.println("Enter your CHOICE");

    }
    public static void gotoLogin(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome to DVD RENTAL STORE                                *");
        System.out.println("***********************************************************************************");
        System.out.println();
        String email, password;
            System.out.print("Enter your email: ");
            email = sc.nextLine();
            System.out.print("Enter your Password_ID: ");
            password = sc.nextLine();
//            System.out.println("Pass: "+password+" "+email+" :email");
            //check into database
            try {
                conn = DriverManager.getConnection(DB_URL,USER,PASS);
                String query = "Select * from buyer where email = ? and buyer_id = ?";
                PreparedStatement ps  = conn.prepareStatement(query);
                ps.setString(1, email);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                int id = -1;
                if(rs.next()){
                    id = rs.getInt(1);
                }
                if(id==-1){
                    System.out.println("Invalid email or password, press 1 to continue or press any button to return to main menu");
                    String choice = sc.nextLine();
                    if(choice.equals("1"))gotoLogin();
                }else{
                    Buyer buyer = new Buyer(id, stmt, conn);
                    buyer.inputMainChoice();
                    return;
                }

            } catch (Exception e) {
            }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static void gotoSignup(){
        System.out.println("***********************************************************************************");
        System.out.println("*                        Welcome Buddy!                                           *");
        System.out.println("***********************************************************************************");
        System.out.println();
        String first, last, stamp, address, postal, phone, email;
        int i = 0;
        System.out.print("Enter First Name: ");
        first = sc.nextLine();
        System.out.print("Enter Last Name: ");
        last = sc.nextLine();
        System.out.print("Enter Email: ");
        email = sc.nextLine();
        System.out.print("Enter Address: ");
        address = sc.nextLine();
        System.out.print("Enter Postal: ");
        postal = sc.nextLine();
        System.out.print("Enter Phone no.: ");
        phone = sc.nextLine();
//        System.out.println("data: "+first+last+email+postal+phone);
        if(email.length()<4 || first.length()==0  || address.length()<3 || postal.length()!=6 || phone.length()!=10){
            System.out.println("Error, please enter correct and valid inputs, please try again\nPress 0 to return to MAIN_MENU\nPress any button to continue");
            String ft = sc.nextLine();
            if(ft.equals("0")){
                printMainScreen();
                return;
            }
            gotoSignup();
            return;
        }

        String query = "Select buyer_id from buyer where email = ? ";
        try{
//            System.out.println("Running query!!");
//            System.out.println(conn);
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            int id = -1;
            while(rs.next()){
                id = rs.getInt("buyer_id");
            }
            if(id!=-1){
                System.out.println("Email Already Registered, \n *Press 0 to try again\n *Press 1 to Login\n *Press any key to Main Menu");
                String ans = sc.nextLine();
                if(ans.equals("1")){
                    gotoLogin();
                    return;
                }else if(ans.equals("0")){
                    gotoSignup();
                    return;
                }
                else{
                    printMainScreen();
                    return;
                }
            }else{
                //means email is unique
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
//                System.out.println(dtf.format(now));
                stamp = dtf.format(now);
                try{
//                    System.out.println("In try block");
                    String addAddress = "insert into addr(address,postal_code,phone) values( ?, ?, ? )";
                    String addUser = "insert into buyer(first_name,last_name,email,addr_id,create_date) values( ?,?,?,?,?)";
                    //Get the ID of this user
//                    System.out.println("Trying to enter data");
                    ps = conn.prepareStatement(addAddress, Statement.RETURN_GENERATED_KEYS);
                    ps.setString(1,address);
                    ps.setString(2,postal);
                    ps.setString(3,phone);
                    ps.executeUpdate();
                    int addr_id = 0;
                    rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        addr_id = rs.getInt(1);
                    }
//                    System.out.println("addr id: "+addr_id);
                    ps = conn.prepareStatement(addUser, Statement.RETURN_GENERATED_KEYS);
                    ps.setString(1,first);
                    ps.setString(2,last);
                    ps.setString(3,email);
                    ps.setInt(4,addr_id);
                    ps.setString(5,stamp);
                    ps.executeUpdate();
                    rs = ps.getGeneratedKeys();
                    int buyer_id = 0;
                    if (rs.next()) {
                        buyer_id = rs.getInt(1);
                    }
                            /////////////////////////////////////////////////////////////////////////////////////////////////
                    System.out.println("Dear User, your password id is: "+buyer_id+"\nPlease save this for future login");
                    /////////////////////////////////////////////////////////////////////////////////////////////////////
                } catch (Exception ex) {
                    System.out.println(ex.toString());
                    System.out.println("Something went wrong, please Signup later");
                    gotoSignup();
                    return;
                }
            }
        } catch (SQLException e) {
            System.out.println("Some error occured "+e.toString());
        }
    }
    public static void gotoEmployee(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome To STORE                                           *");
        System.out.println("***********************************************************************************");
        System.out.println();
        String email, password;
        System.out.print("Enter your email: ");
        email = sc.nextLine();
        System.out.print("Enter your password: ");
        password = sc.nextLine();
        password = pashash(password);
//        System.out.println("Pass: "+password+" "+email+" :email");
        //check into database
        String query = "Select employee_id from employee where email = ? and password = ? ";
        try {
            conn = DriverManager.getConnection(DB_URL,USER,PASS);
//            String query = "Select * from buyer where email = ? and buyer_id = ?";
            PreparedStatement ps  = conn.prepareStatement(query);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            int id = -1;
            if(rs.next()){
                id = rs.getInt(1);
            }
            if(id==-1){
                System.out.println("Invalid email or password, press 1 to continue or press any button to return to main menu");
                String choice = sc.nextLine();
                if(choice.equals("1"))gotoLogin();
            }else{
                //todo
                employee emp = new employee(id, conn);
                return;
            }

        } catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }
    }

    public static void gotoInvestor(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome To STORE                                           *");
        System.out.println("***********************************************************************************");
        System.out.println();
        String email, password;
        System.out.print("Enter your email: ");
        email = sc.nextLine();
        System.out.print("Enter your password: ");
        password = sc.nextLine();
        password = pashash(password);
//        System.out.println("Pass: "+password+" "+email+" :email");
        //check into database
        String query = "Select investor_id from investor where email = ? and password = ? ";
        try {
            conn = DriverManager.getConnection(DB_URL,USER,PASS);
//            String query = "Select * from buyer where email = ? and buyer_id = ?";
            PreparedStatement ps  = conn.prepareStatement(query);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            int id = -1;
            if(rs.next()){
                id = rs.getInt(1);
            }
            if(id==-1){
                System.out.println("Invalid email or password, press 1 to continue or press any button to return to main menu");
                String choice = sc.nextLine();
                if(choice.equals("1"))gotoLogin();
            }else{
                Investor inv = new Investor(id, conn);
                return;
            }

        } catch (Exception e) {
            System.out.println("Something went wrong error: "+e.toString());
        }

    }
    public static void gotoAdmin(){
        //admin just need some password
        //Do Hashing here
        System.out.print("Enter Password: ");
        String pass = sc.nextLine();
        pass = pashash(pass);
        //fetch password from database
        String dbpass = "";
        String q = "Select passwd from admin_pass";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                dbpass = rs.getString(1);
            }
        } catch (Exception e) {
            System.out.println("Something went wrong, error:"+e.toString());
            return;
        }
//        System.out.println("DBpass: "+dbpass+"\nPass: "+pass);

        if(!pass.equals(dbpass)){
            System.out.println("Invalid Password, Access Denied");
            return;
        }
        System.out.println("**************************WELCOME MASTER*********************************");
        Admin admin = new Admin(conn);
    }

    public static void inputMainChoice(){
        int i = -1;
        do{
            printMainScreen();
            String in = sc.nextLine();
            try{
                i = Integer.parseInt(in);
                switch(i){
                    case 1: gotoLogin(); printMainScreen(); break;
                    case 2: gotoSignup(); printMainScreen();break;
                    case 3: gotoInvestor();printMainScreen(); break;
                    case 4: gotoEmployee(); printMainScreen();break;
                    case 5: gotoAdmin(); printMainScreen();break;
                    case 0: break;
                    default:System.out.println("Please enter a valid choice from default");break;
                }
            }catch (Exception e){
                System.out.println("Please enter a valid choice, exp ");
            }
        }while(i!=0);
    }

    public static void customTabPrint2(List<String[]>list) {

        boolean leftJustifiedRows = true;
        int maxWidth = 30;
        List<String[]> tableList = list;
        List<String[]> finalTableList = new ArrayList<>();
        for (String[] row : tableList) {
            // If any cell data is more than max width, then it will need extra row.
            boolean needExtraRow = false;
            // Count of extra split row.
            int splitRow = 0;
            do {
                needExtraRow = false;
                String[] newRow = new String[row.length];
                for (int i = 0; i < row.length; i++) {
                    // If data is less than max width, use that as it is.
                    if (row[i].length() < maxWidth) {
                        newRow[i] = splitRow == 0 ? row[i] : "";
                    } else if ((row[i].length() > (splitRow * maxWidth))) {
                        // If data is more than max width, then crop data at maxwidth.
                        // Remaining cropped data will be part of next row.
                        int end = row[i].length() > ((splitRow * maxWidth) + maxWidth)
                                ? (splitRow * maxWidth) + maxWidth
                                : row[i].length();
                        newRow[i] = row[i].substring((splitRow * maxWidth), end);
                        needExtraRow = true;
                    } else {
                        newRow[i] = "";
                    }
                }
                finalTableList.add(newRow);
                if (needExtraRow) {
                    splitRow++;
                }
            } while (needExtraRow);
        }
        String[][] finalTable = new String[finalTableList.size()][finalTableList.get(0).length];
        for (int i = 0; i < finalTable.length; i++) {
            finalTable[i] = finalTableList.get(i);
        }
        Map<Integer, Integer> columnLengths = new HashMap<>();
        Arrays.stream(finalTable).forEach(a -> Stream.iterate(0, (i -> i < a.length), (i -> ++i)).forEach(i -> {
            if (columnLengths.get(i) == null) {
                columnLengths.put(i, 0);
            }
            if (columnLengths.get(i) < a[i].length()) {
                columnLengths.put(i, a[i].length());
            }
        }));
        final StringBuilder formatString = new StringBuilder("");
        String flag = leftJustifiedRows ? "-" : "";
        columnLengths.entrySet().stream().forEach(e -> formatString.append("| %" + flag + e.getValue() + "s "));
        formatString.append("|\n");
        String line = columnLengths.entrySet().stream().reduce("", (ln, b) -> {
            String templn = "+-";
            templn = templn + Stream.iterate(0, (i -> i < b.getValue()), (i -> ++i)).reduce("", (ln1, b1) -> ln1 + "-",
                    (a1, b1) -> a1 + b1);
            templn = templn + "-";
            return ln + templn;
        }, (a, b) -> a + b);
        line = line + "+\n";
        System.out.print(line);
        Arrays.stream(finalTable).limit(1).forEach(a -> System.out.printf(formatString.toString(), a));
        System.out.print(line);

        Stream.iterate(1, (i -> i < finalTable.length), (i -> ++i))
                .forEach(a -> System.out.printf(formatString.toString(), finalTable[a]));
        System.out.print(line);
    }


    public static void customTabPrint(List<String[]>list) {

        boolean leftJustifiedRows = true;
        int aa = 1, bb, c = 0;
        int maxWidth = 30;
        c++;
        List<String[]> tableList = list;
        aa--;
        List<String[]> finalTableList = new ArrayList<>();
        for (String[] row : tableList) {
            // If any cell data is more than max width, then it will need extra row.
            if(aa==1)aa++;
            boolean needExtraRow = false;
            // Count of extra split row.
            if(aa!=1)
            {
                aa--;
                c++;
            }
            int splitRow = 0;
            do {
                needExtraRow = false;
                String[] newRow = new String[row.length];
                for (int i = 0; i < row.length; i++) {
                    aa = bb = c = 0;
                    StringBuilder ss = new StringBuilder();
                    // If data is less than max width, use that as it is.
                    if (row[i].length() < maxWidth) {
                        ss.append("-");
                        newRow[i] = splitRow == 0 ? row[i] : "";
                    } else if ((row[i].length() > (splitRow * maxWidth))) {
                        ss.append("\t");
                        int end = row[i].length() > ((splitRow * maxWidth) + maxWidth)
                                ? (splitRow * maxWidth) + maxWidth
                                : row[i].length();
                        ss.append("\n");
                        newRow[i] = row[i].substring((splitRow * maxWidth), end);
                        needExtraRow = true;
                    } else {
                        ss.append("_");
                        newRow[i] = "";
                    }
                }
                finalTableList.add(newRow);
                aa = bb = 0;
                c = -1;
                if (needExtraRow) {
                    splitRow++;
                }
            } while (needExtraRow);
        }
        StringBuilder sq = new StringBuilder();
        sq.append("-");
        String[][] finalTable = new String[finalTableList.size()][finalTableList.get(0).length];
        aa++;
        for (int i = 0; i < finalTable.length; i++) {
            finalTable[i] = finalTableList.get(i);
        }
        sq.append("\n\n");
        Map<Integer, Integer> columnLengths = new HashMap<>();
        sq.append("\\");
        Arrays.stream(finalTable).forEach(a -> Stream.iterate(0, (i -> i < a.length), (i -> ++i)).forEach(i -> {
            if (columnLengths.get(i) == null) {
                columnLengths.put(i, 0);
            }
            if (columnLengths.get(i) < a[i].length()) {
                columnLengths.put(i, a[i].length());
            }
        }));
        aa++;
        bb = 0;

        final StringBuilder formatString = new StringBuilder("");
        String flag = leftJustifiedRows ? "-" : "";
        bb = bb ==0? aa:bb;
        columnLengths.entrySet().stream().forEach(e -> formatString.append("| %" + flag + e.getValue() + "s "));
        formatString.append("|\n");
        String line = columnLengths.entrySet().stream().reduce("", (ln, b) -> {
            String templn = "+-";
            templn = templn + Stream.iterate(0, (i -> i < b.getValue()), (i -> ++i)).reduce("", (ln1, b1) -> ln1 + "-",
                    (a1, b1) -> a1 + b1);
            templn = templn + "-";
            return ln + templn;
        }, (a, b) -> a + b);
        aa = 0;
        bb = 0;
        line = line + "+\n";
        System.out.print(line);
        System.out.print("");
        Arrays.stream(finalTable).limit(1).forEach(a -> System.out.printf(formatString.toString(), a));
        System.out.print(line);
        aa++;
        bb++;
        Stream.iterate(1, (i -> i < finalTable.length), (i -> ++i))
                .forEach(a -> System.out.printf(formatString.toString(), finalTable[a]));
        System.out.print(line);
    }

    public static String pashash(String password){
        int a = 0, b= 0;
        String passwordToHash = password;
        StringBuilder str = new StringBuilder();
        String generatedPassword = null;
        try {
            str.append("a1");
            StringBuilder str2 = new StringBuilder();
            MessageDigest md = MessageDigest.getInstance("MD5");
            str2.append("b1");
            md.update(passwordToHash.getBytes());
            byte[] bytes = md.digest();
            int len = bytes.length;
            StringBuilder sb = new StringBuilder();
            a = len;
            b = a;
            for(int i=0; i< bytes.length ;i++)
            {
                sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
            }

            return generatedPassword = sb.toString();
        }
        catch (NoSuchAlgorithmException e)
        {
            e.printStackTrace();
        }
        return generatedPassword;
    }


//    public static void customTabPrint2(List<String[]>list) {
//
//        List<String[]> finalTableList = new ArrayList<>();
//        int maxhight=22,maxWidth = 30;
//        boolean flag2=false;
//        List<String[]> tableList = list;
//        boolean flag1=true;
//        boolean leftJustifiedRows = true;
//        boolean flag3=false;
//        for (String[] row : tableList) {
//            // Count of extra split row.
//            int splitRow = 0;
//            // If any cell data is more than max width, then it will need extra row.
//            boolean needExtraRow = false;
//
//            do {
//
//                String[] newRow = new String[row.length];
//                needExtraRow = false;
//                int i=0;
//                while(i<row.length){
//                    // If data is less than max width, use that as it is.
//                    if (flag3 || row[i].length() < maxWidth) {
//                        if(splitRow==0) newRow[i]=row[i];
//                        else newRow[i]="";
//                    } else if (flag1 && (row[i].length() - (splitRow * maxWidth) > 0) ) {
//                        // If data is more than max width, then crop data at maxwidth.
//                        // Remaining cropped data will be part of next row.
//                        needExtraRow = true;
//                        int end;
//                        if(row[i].length() > ((splitRow * maxWidth) + maxWidth)) end=(splitRow * maxWidth) + maxWidth;
//                        else end= row[i].length();
//                        newRow[i] = row[i].substring((splitRow * maxWidth), end);
//
//                    } else {
//                        newRow[i] = "";
//                    }
//                    i++;
//                }
//                finalTableList.add(newRow);
//                if (flag2 || needExtraRow) {
//                    splitRow++;
//                }
//            } while (flag1 && needExtraRow);
//        }
//        Map<Integer, Integer> columnLengths = new HashMap<>();
//        int ij=0;
//        String[][] finalTable = new String[finalTableList.size()][finalTableList.get(0).length];
//        while(ij<finalTable.length){
//            finalTable[ij] = finalTableList.get(ij);
//            ij++;
//        }
//        int arl=0,arl1=0;
//        Arrays.stream(finalTable).forEach(a -> Stream.iterate(arl1, (i -> i < a.length), (i -> ++i)).forEach(i -> {
//
//            if (columnLengths.get(i) == null) {
//                columnLengths.put(i, 0);
//            }
//            if (columnLengths.get(i) - a[i].length() < 0) {
//
//                columnLengths.put(i, a[i].length());
//            }
//        }));
//        String flag;
//        final StringBuilder formatString = new StringBuilder("");
//        if(leftJustifiedRows) flag="-";
//        else flag="";
//        columnLengths.entrySet().stream().forEach(e -> formatString.append("| %" + flag + e.getValue() + "s "));
//        arl=arl*2;
//        formatString.append("|\n");
//        flag3=false;
//        String line = columnLengths.entrySet().stream().reduce("", (ln, b) -> {
//            int ser=0;
//            String templn = "+-";
//            String str1="",str2="-";
//            templn=templn+ Stream.iterate(ser, (i -> i < b.getValue()), (i -> ++i)).reduce(str1, (ln1, b1) -> ln1 + str2,(a1, b1) -> a1 + b1);
//            templn=templn+"-";
//            return ln + templn;
//        }, (a, b) -> a + b);
//        int strint=0;
//        line = line + "+\n";
//        flag2=false;
//        System.out.print(line);
//        strint+=1;
//        Arrays.stream(finalTable).limit(1).forEach(a -> System.out.printf(formatString.toString(), a));
//        if(!flag2) System.out.print(line);
//        Stream.iterate(strint+1, (i -> i < finalTable.length), (i -> ++i))
//                .forEach(a -> System.out.printf(formatString.toString(), finalTable[a]));
//        boolean flag4=true;
//        System.out.print(line);
//    }
}