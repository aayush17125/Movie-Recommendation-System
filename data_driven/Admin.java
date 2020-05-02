import java.awt.desktop.SystemSleepEvent;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.regex.Pattern;

//import static java.util.jar.Pack200.Packer.PASS;

public class Admin {
    static Scanner sc = new Scanner(System.in);
    static Connection conn;
    public Admin(Connection connection){
        conn = connection;
        inputChoice();
    }
    public static void AdminChart(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome to DVD RENTAL STORE                                *");
        System.out.println("***********************************************************************************");
        System.out.println("*\t(1) Press 1 to Display all name and addresses employees                        *");
        System.out.println("*\t(2) Press 2 to Display total transactions by each employee                     *");
        System.out.println("*\t(3) Press 3 to Display all name and addresses of Investors                     *");
        System.out.println("*\t(4) Press 4 to Display total investment by each Investor                       *");
        System.out.println("*\t(5) Press 5 Add an employee                                                    *");
        System.out.println("*\t(6) Press 6 Add an Investor                                                    *");
        System.out.println("*\t(7) Press 7 to show investments                                                *");
        System.out.println("*\t(8) Press 8 to show top 3 most spending customers                              *");
        System.out.println("*\t(9) Press 9 to show sales by each category                                     *");
        System.out.println("*\t(10) Press 10 to show total sales FY                                           *");
        System.out.println("*\t(11) Press 11 to show total sales FM                                           *");
        System.out.println("*\t(12) Press 12 to show total sales on some date                                 *");
        System.out.println("*\t(13) Press 13 to show total investment FY                                      *");
        System.out.println("*\t(14) Press 14 to show total investment specific month                          *");
        System.out.println("*\t(15) Press 15 to show total investment on some date                            *");
        System.out.println("*\t(16) Press 16 to show total sales with movies count                            *");
        System.out.println("*\t(17) Press 17 to Update your password                                          *");
        System.out.println("*\t(18) Press 18 to get count of users registered                                 *");
        System.out.println("*\t(19) Press 19 to add a Movie                                                   *");
        System.out.println("*\t(20) Press 0 to EXIT/LOGOUT                                                    *");
        System.out.println("***********************************************************************************");
        System.out.print("Input your choice: ");
    }

    public static void addMov(){
        System.out.print("Enter movie name: ");
        String title = sc.nextLine();
        System.out.print("Release Year: ");
        String year = sc.nextLine();
        System.out.print("Rental Duration: ");
        String rentdura = sc.nextLine();
        System.out.print("Rental Rate: ");
        String rate = sc.nextLine();
        System.out.print("Length: ");
        String len = sc.nextLine();
        System.out.print("Rating: ");
        String rating = sc.nextLine();
        System.out.print("Enter Category: ");
        String cat = sc.nextLine();
        System.out.print("Enter no. of actors: ");
        String noa = sc.nextLine();
        int rat, l, no = 0;
        try{
            rat = Integer.parseInt(rate);
            l = Integer.parseInt(len);
            no = Integer.parseInt(noa);
        }catch (Exception e){
            System.out.println("Please enter valid inputs ");
            return;
        }
        //write into movies table
        String q = "Insert into movie(title, release_year, rental_duration, rental_rate, length, rating, last_update)\n" +
                "values(?,?,?,?,?,?,?)";
        //get current date
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        LocalDateTime now = LocalDateTime.now();
        String stamp = dtf.format(now);
        try{
            //get category id
            String q2 = "Select category_id from category where name = ?";
            PreparedStatement ps2 = conn.prepareStatement(q2, Statement.RETURN_GENERATED_KEYS);
            ps2.setString(1,cat);
            int catid =  -1;
            ResultSet rs = ps2.executeQuery();
            while (rs.next()){
                catid = rs.getInt(1);
            }
            if(catid==-1){
                System.out.println("Invalid Category, returning to previous menu");
                return;
            }
            PreparedStatement ps = conn.prepareStatement(q, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1,title);
            ps.setString(2,year);
            ps.setString(3,rentdura);
            ps.setInt(4,rat);
            ps.setInt(5,l);
            ps.setString(6,rating);
            ps.setString(7,stamp);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            int mid = -1;
            while(rs.next()){
                mid = rs.getInt(1);
            }
            //add into category
            System.out.println("mid: "+mid);
            q = "Insert into movie_category(movie_id, category_id) values(?,?)";
            ps = conn.prepareStatement(q);
            ps.setInt(1,mid);
            ps.setInt(2, catid);
            ps.executeUpdate();
            //add all the actors
            for(int i =0; i<no; i++){
                String fn, ln;
                System.out.print((i+1)+"Enter actor's first name: ");
                fn = sc.nextLine();
                System.out.print((i+1)+"Enter actor's last name: ");
                ln = sc.nextLine();
                addactors(fn, ln, mid);

            }

            System.out.println("Movie added Successfully, press any key to return to previous menu");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }


    }

    public static void addactors(String f, String l, int mid) throws SQLException {
        String q = "Select actor_id from actor where first_name = ? and last_name = ?";
        PreparedStatement ps = conn.prepareStatement(q, Statement.RETURN_GENERATED_KEYS);
        ps.setString(1,f);
        ps.setString(2, l);
        int aid = -1;
        ResultSet rs = ps.executeQuery();
        System.out.println("Before adding actor_id");
        while (rs.next()){
            aid = rs.getInt("actor_id");
        }
        if(aid==-1){
            //means actor doesnot exists,
            System.out.println("Adding new Actor: "+f+" "+l);
            q = "Insert into actor(first_name, last_name) values(?,?)";
            ps = conn.prepareStatement(q, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1,f);
            ps.setString(2, l);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            while (rs.next()){
                aid = rs.getInt(1);
            }
        }
        //now insert into movie category
//        System.out.println("actor id: "+aid);
        q = "Insert into movie_actor (actor_id, movie_id) values(?,?)";
        ps = conn.prepareStatement(q);
        ps.setInt(1,aid);
        ps.setInt(2,mid);
        ps.executeUpdate();
    }

    public static void inputChoice(){
        int i = -1;
        do{
            AdminChart();
            String choice = sc.nextLine();
            try{
                i = Integer.parseInt(choice);
                switch (i){
                    case 0: return;
                    case 1: DisplayEmpData(); break;
                    case 2: TotalTransbyEmp(); break;
                    case 3: DisplayInvestorData(); break;
                    case 4: totalInvestmentbyInvestor(); break;
                    case 5: addEmp(); break;
                    case 6: addInv(); break;
                    case 7: showInvestmentsFF(); break;
                    case 8: mostSpendingCustomer();break;
                    case 9: SalesByCategory(); break;
                    case 10: TotalSalesFY(); break;
                    case 11: TotalSalesFM(); break;
                    case 12: TotalSalesFD(); break;
                    case 13: showInvestmentsFY(); break;
                    case 14: showInvestmentsFM(); break;
                    case 15: showInvestmentsFD(); break;
                    case 16: salesByMovie(); break;
                    case 17: editpass(); break;
                    case 18: countUser(); break;
                    case 19: addMov(); break;
                    default: System.out.println("Enter valid input"); break;
                }
            }catch(Exception e){
                System.out.println("Please enter a valid number");
            }
            
        }while(i!=0);
    }

    public static void countUser(){
        System.out.println("Hint just add year/month to search no. of user added in that year/month");
        System.out.print("Enter date(YYYY-MM-DD)");
        String date = sc.nextLine();
        String q = "Select count(*) from buyer where create_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1,date+"%");
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"Count"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[1];
                int i =0;
                ar[i++] = rs.getString(1);
//                ar[i++] = rs.getString(2);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    private static void editpass() {
        String pass;
        System.out.print("Enter old password:");
        String temp_pass = sc.nextLine();
        temp_pass = Movie.pashash(temp_pass);
        try {

            String qq = "Select passwd from admin_pass";
            PreparedStatement ps = conn.prepareStatement(qq);
            ResultSet rs = ps.executeQuery();
            String password = "";
            while (rs.next()){
                password = rs.getString(1);
            }
            if(!temp_pass.equals(password)){
                System.out.println("Old password does not match, press any key to return to previous menu");
                sc.nextLine();
                return;
            }
            System.out.println("Enter new password");
            pass  = sc.nextLine();
            pass = Movie.pashash(pass);
            if(pass.length()<3){
                System.out.println("Password length too short, press any key to return to previous menu");
                sc.nextLine();
                return;
            }

            String query3 = "UPDATE admin_pass\n" +
                    "SET passwd = ?";
             ps = conn.prepareStatement(query3);
            ps.setString(1, pass);
            ps.executeUpdate();
            System.out.println("Password successfully updated");
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());

        }
    }

    public static void salesByMovie() {
        if(conn==null){
            conn = Movie.conn;
        }
        String q = "SELECT tb1.mid 'movie id',m.title 'movie name',tb1.cs AS 'copies sold',tb1.s 'Sales' FROM \n" +
                "(SELECT r.movie_id AS mid,COUNT(*) AS cs,SUM(t.amount) AS s \n" +
                "FROM rental r JOIN payment t ON t.rental_id=r.rental_id\n" +
                "GROUP BY r.movie_id) AS tb1 JOIN movie m ON m.movie_id=tb1.mid \n" +
                "order by s desc;";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"Movie ID", "Movie Name", "Copies Sold", "Revenue Made"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[4];
                int i =0;
                ar[i++] = rs.getString(1);
                ar[i++] = rs.getString(2);
                ar[i++] = rs.getString(3);
                ar[i++] = rs.getString(4);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key for previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }
    }

    private static void DisplayEmpData() {
        String q = "select emp.first_name, emp.last_name, addr.address \n" +
                "from employee emp\n" +
                "left join addr\n" +
                "on emp.addr_id = addr.addr_id;\n";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"First Name", "Last Name", "Address"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[3];
                int i =0;
                ar[i++] = rs.getString(1);
                ar[i++] = rs.getString(2);
                ar[i++] = rs.getString(3);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key for previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }
    }
    private static void TotalTransbyEmp() {
        String q = "SELECT tb1.eid,CONCAT(employee.first_name,' ',employee.last_name) AS Name, tb1.sum FROM\n" +
                "(SELECT employee_id eid, SUM(amount) sum FROM payment GROUP BY employee_id\n" +
                "ORDER BY SUM(amount) desc) AS tb1 JOIN employee ON tb1.eid=employee.employee_id";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] ar1 = new String[]{"ID", "FULL NAME", "TRANSACTION AMOUNT"};
            ArrayList<String[]> a = new ArrayList<>();
            a.add(ar1);
            while(rs.next()){
                String[]ar = new String[3];
                int i =0;
                ar[i++] = ""+rs.getInt(i);
                ar[i++] = rs.getString(i);
                ar[i++] = rs.getString(i);
                a.add(ar);
            }
            Movie.customTabPrint(a);
            System.out.println("********************************************************************************");
            System.out.print("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    public static void DisplayInvestorData(){
        String q = "select emp.first_name, emp.last_name, addr.address \n" +
                "from investor emp\n" +
                "left join addr\n" +
                "on emp.addr_id = addr.addr_id;\n";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"First Name", "Last Name", "Address"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[3];
                int i =0;
                ar[i++] = rs.getString(1);
                ar[i++] = rs.getString(2);
                ar[i++] = rs.getString(3);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key for previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }
    }
    public static void totalInvestmentbyInvestor(){
        String q = "SELECT tb1.eid,CONCAT(investor.first_name,' ',investor.last_name) AS Name, tb1.sum FROM\n" +
                "(SELECT investor_id eid, SUM(amount) sum FROM investment GROUP BY investor_id\n" +
                "ORDER BY SUM(amount) desc) AS tb1 JOIN investor ON tb1.eid=investor.investor_id;";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] ar1 = new String[]{"ID", "FULL NAME", "TRANSACTION AMOUNT"};
            ArrayList<String[]> a = new ArrayList<>();
            a.add(ar1);
            while(rs.next()){
                String[]ar = new String[3];
                int i =0;
                ar[i++] = ""+rs.getInt(i);
                ar[i++] = rs.getString(i);
                ar[i++] = rs.getString(i);
                a.add(ar);
            }
            Movie.customTabPrint(a);
            System.out.println("********************************************************************************");
            System.out.print("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }

    private static void addInv() {
        System.out.print("Enter Investor's first name: ");
        String fn = sc.nextLine();
        System.out.print("Enter Investor's last name: ");
        String ln = sc.nextLine();
        System.out.print("Enter Investor's Email: ");
        String em = sc.nextLine();
        System.out.print("Enter Investor's password: ");
        String pass = sc.nextLine();
        System.out.print("Enter Investor's address: ");
        String addr = sc.nextLine();
        System.out.print("Enter Investor's phone no.: ");
        String phn = sc.nextLine();
        System.out.print("Enter Investor's postal: ");
        String pos = sc.nextLine();
        System.out.print("Enter Investor's initial funding: ");
        String fund = sc.nextLine();
        int f = 0;
        try{
            f = Integer.parseInt(fund);
            if(f<0){
                System.out.println("Fund can't be negative, press any key to return to previous menu");
                sc.nextLine();
                return;
            }
        }catch (Exception e){
            System.out.println("Enter a valid fund value, press any key to return to previous menu");
            sc.nextLine();
            return;
        }
        //write into database
        if(fn.length()<2 || pos.length()!=6 || phn.length()!=10 || (!phn.matches("[0-9]+")) || (!pos.matches("[0-9]+")) || pass.length()<3){
            System.out.println("Please enter valid inputs, returning to previous menu");return;
        }
        pass = Movie.pashash(pass);
        try {
            String q = "Select investor_id from investor where email = ? ";
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, em);
            ResultSet rs = ps.executeQuery();
            int id = - 1;
            while(rs.next()){
                id = rs.getInt("investor_id");
            }
            if(id!=-1){
                System.out.println("Email already registered, returning to previous menu");
            }else{
                //add address
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
                String stamp = dtf.format(now);
                String addAddress = "insert into addr(address,postal_code,phone) values( ?, ?, ? )";
                String addUser = "insert into investor(first_name,last_name,email,password,addr_id,create_date,initial_investment) values( ?,?,?,?,?,?,?)";
                //Get the ID of this user
//                System.out.println("Trying to enter data");
                ps = conn.prepareStatement(addAddress, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1,addr);
                ps.setString(2,pos);
                ps.setString(3,phn);
                ps.executeUpdate();
                int addr_id = 0;
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    addr_id = rs.getInt(1);
                }
//                System.out.println("addr id: "+addr_id);
                ps = conn.prepareStatement(addUser, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1,fn);
                ps.setString(2,ln);
                ps.setString(3,em);
                ps.setString(4,pass);
                ps.setInt(5,addr_id);
                ps.setString(6,stamp);
                ps.setInt(7,f);
                ps.executeUpdate();
                rs = ps.getGeneratedKeys();
                int inst_id = 0;
                if (rs.next()) {
                    inst_id = rs.getInt(1);
                }
//                System.out.println("Investor id: "+inst_id);
                //add a investment relation for storing all updated investment :
                String investment = "insert into investment(investor_id,amount,payment_date) values( ?,?,?)";
                ps = conn.prepareStatement(investment);
                ps.setInt(1, inst_id);
                ps.setInt(2, f);
                ps.setString(3, stamp);
                ps.executeUpdate();
                System.out.println("Investor added successfully! press any key to return to previous menu");
                sc.nextLine();
            }

        } catch (Exception e) {
            System.out.println("Something went wrong, "+ e.toString());
        }
    }

    private static void addEmp() {
        System.out.print("Enter employee's first name: ");
        String fn = sc.nextLine();
        System.out.print("Enter employee's last name: ");
        String ln = sc.nextLine();
        System.out.print("Enter employee's Email: ");
        String em = sc.nextLine();
        System.out.print("Enter employee's username: ");
        String username = sc.nextLine();
        System.out.print("Enter employee's password: ");
        String pass = sc.nextLine();
        //if trying hashing... just change this string and call the function
        System.out.print("Enter employee's address: ");
        String addr = sc.nextLine();
        System.out.print("Enter employee's phone no.: ");
        String phn = sc.nextLine();
        System.out.print("Enter employee's postal: ");
        String pos = sc.nextLine();
        //write into database
        if(fn.length()<2 || pos.length()!=6 || phn.length()!=10 || (!phn.matches("[0-9]+")) || (!pos.matches("[0-9]+"))  || pass.length()<3){
            System.out.println("Please enter valid inputs, returning to previous menu");return;
        }
        pass = Movie.pashash(pass);
        try {
            String q = "Select employee_id from employee where email = ? ";
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, em);
            ResultSet rs = ps.executeQuery();
            int id = - 1;
            while(rs.next()){
                id = rs.getInt("employee_id");
            }
            if(id!=-1){
                System.out.println("Email already registered, returning to previous menu");
            }else{
                //add address
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
                String stamp = dtf.format(now);
                String addAddress = "insert into addr(address,postal_code,phone) values( ?, ?, ? )";
                String addUser = "insert into employee(first_name, last_name, addr_id, email, active, username, password) values( ?,?,?,?,?,?,?)";
                //Get the ID of this user
//                System.out.println("Trying to enter data");
                ps = conn.prepareStatement(addAddress, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1,addr);
                ps.setString(2,pos);
                ps.setString(3,phn);
                ps.executeUpdate();
                int addr_id = 0;
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    addr_id = rs.getInt(1);
                }
//                System.out.println("addr id: "+addr_id);
                ps = conn.prepareStatement(addUser, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1,fn);
                ps.setString(2,ln);
                ps.setInt(3,addr_id);
                ps.setString(4,em);
                ps.setBoolean(5,true);
                ps.setString(6,username);
                ps.setString(7, pass);
                ps.executeUpdate();
                rs = ps.getGeneratedKeys();
                int buyer_id = 0;
                if (rs.next()) {
                    buyer_id = rs.getInt(1);
                }
                System.out.println("employee added successfully, press any key to return to main menu");
                sc.nextLine();
            }
        } catch (Exception e) {
            System.out.println("Something went wrong, "+ e.toString());
        }
    }
    public static void showInvestmentsFF(){
        String q = "Select sum(amount) as sum from investment ";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String fund = "0";
            while(rs.next()){
                fund = rs.getString("sum");
            }
            System.out.println("Total Investment made: "+fund+" Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong!, error: "+e.toString());
        }
    }
    public static void showInvestmentsFD(){
        System.out.print("Enter Year(YYYY-MM-DD) to get total Investments: ");
        String year = sc.nextLine();
        String q = "Select sum(amount) as sum from investment where payment_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String fund = "0";
            while(rs.next()){
                fund = rs.getString("sum");
            }
            System.out.println("Total Investment made: "+fund+" Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong!, error: "+e.toString());
        }
    }
    public static void showInvestmentsFM(){
        System.out.print("Enter Year(YYYY-MM) to get total Investments: ");
        String year = sc.nextLine();
        String q = "Select sum(amount) as sum from investment where payment_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String fund = "0";
            while(rs.next()){
                fund = rs.getString("sum");
            }
            System.out.println("Total Investment made: "+fund+" Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong!, error: "+e.toString());
        }
    }
    public static void showInvestmentsFY(){
        System.out.print("Enter Year(YYYY) to get total Investments: ");
        String year = sc.nextLine();
        String q = "Select sum(amount) as sum from investment where payment_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String fund = "";
            while(rs.next()){
                fund = rs.getString("sum");
            }
            System.out.println("Total Investment made: "+fund+" FY= "+year+" Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong!, error: "+e.toString());
        }
    }
    public static void mostSpendingCustomer(){
        String q = "SELECT tb1.bid,CONCAT(buyer.first_name,' ',buyer.last_name) AS Name, tb1.sum from\n" +
                "(select buyer_id bid, sum(amount) as sum from payment group by buyer_id order by sum desc) as tb1 join buyer\n" +
                "on tb1.bid = buyer.buyer_id\n" +
                "Limit 3";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] ar = new String[]{"ID", "Name", "Amount"};
            ArrayList<String[]> arr = new ArrayList<>();
            arr.add(ar);
            while (rs.next()){
                String a[] = new String[3];
                int i =0;
                a[i++] = rs.getString(i);
                a[i++] = rs.getString(i);
                a[i++] = rs.getString(i);
                arr.add(a);
            }
            Movie.customTabPrint(arr);
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }


    public static void TotalSalesFM(){
        System.out.print("Enter year(YYYY-MM): ");
        String year = sc.nextLine();
        String q = "Select sum(amount) from payment where payment_date like ?";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String ans = "0";
            while (rs.next()){
                ans = rs.getString(1);
            }
            System.out.println("Total Sales: "+ans);
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    public static void TotalSalesFD(){
        System.out.print("Enter year(YYYY-MM-DD): ");
        String year = sc.nextLine();
        String q = "Select sum(amount) from payment where payment_date like ?";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String ans = "0";
            while (rs.next()){
                ans = rs.getString(1);
            }
            System.out.println("Total Sales: "+ans);
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    public static void TotalSalesFY(){
        System.out.print("Enter year(YYYY): ");
        String year = sc.nextLine();
        String q = "Select sum(amount) from payment where payment_date like ?";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, year+"%");
            ResultSet rs = ps.executeQuery();
            String ans = "0";
            while (rs.next()){
                ans = rs.getString(1);
            }
            System.out.println("Total Sales: "+ans+" FY: "+year);
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    //todo
    public static void SalesByCategory() {
        String q = "SELECT c.name 'Category Name',COUNT(*) 'Movies Sold',SUM(m.rental_rate) 'Revenue Made'\n" +
                "FROM rental r JOIN movie m ON r.movie_id=m.movie_id JOIN movie_category mc ON mc.movie_id=r.movie_id JOIN category c ON c.category_id=mc.category_id\n" +
                "GROUP BY mc.category_id\n" +
                "ORDER BY SUM(m.rental_rate) DESC";
        if(conn==null){
            conn = Movie.conn;
        }
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ResultSet rs = ps.executeQuery();
            String[] ar = new String[]{"ID", "Name", "Amount"};
            ArrayList<String[]> arr = new ArrayList<>();
            arr.add(ar);
            while (rs.next()){
                String a[] = new String[3];
                int i =0;
                a[i++] = rs.getString(i);
                a[i++] = rs.getString(i);
                a[i++] = rs.getString(i);
                arr.add(a);
            }
            Movie.customTabPrint(arr);
            System.out.println("Press any key to continue");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }


    }
}


