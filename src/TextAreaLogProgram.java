import com.ericsson.otp.erlang.*;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.io.PrintStream;


public class TextAreaLogProgram extends JFrame{
    //private JTextArea textArea;

    //private JButton buttonStart = new JButton("Start");

    private PrintStream standardOut;

    private OtpConnection consumerConn;
    private OtpConnection loanBrokerConn;
    private OtpConnection creditAgencyConn;
    private OtpConnection lenderConn;
    private OtpConnection bankQuoteCon;
    private OtpConnection bank1Con;

    private OtpMbox cons;
    private JFrame frame;
    private JButton startButton;
    private JTextField textField1;
    private JTextArea textArea1;
    private JTextArea textArea2;
    private JTextArea textArea3;
    private JTextArea textArea4;
    private JTextArea textArea5;
    private JTextArea textArea6;
    private JPanel framePanel;

    private TextAreaLogProgram() throws IOException, OtpAuthException {
        super("Попытка получить информацию с удаленных модулей erlang");
        setContentPane(framePanel);

        PrintStream printStream1 = new PrintStream(new CustomOutputStream(textArea1));
        PrintStream printStream2 = new PrintStream(new CustomOutputStream(textArea2));
        PrintStream printStream3 = new PrintStream(new CustomOutputStream(textArea3));
        PrintStream printStream4 = new PrintStream(new CustomOutputStream(textArea4));
        PrintStream printStream5 = new PrintStream(new CustomOutputStream(textArea5));
        PrintStream printStream6 = new PrintStream(new CustomOutputStream(textArea6));

        // keeps reference of standard output stream
        standardOut = System.out;

        // re-assigns standard output stream and error output stream
        System.setOut(printStream1);
        System.setErr(printStream1);

        System.setOut(printStream2);
        System.setErr(printStream2);

        System.setOut(printStream3);
        System.setErr(printStream3);

        System.setOut(printStream4);
        System.setErr(printStream4);

        System.setOut(printStream5);
        System.setErr(printStream5);

        System.setOut(printStream6);
        System.setErr(printStream6);


        // adds event handler for button Start
        startButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                textArea1.setText("");
                textArea2.setText("");
                textArea3.setText("");
                textArea4.setText("");
                textArea5.setText("");
                textArea6.setText("");
                try {
                    createConnections();
                } catch (IOException | OtpAuthException e) {
                    e.printStackTrace();
                }
                try {
                    sendingRPC(Integer.parseInt(textField1.getText()));
                } catch (IOException e) {
                    e.printStackTrace();
                }
                try {
                    Thread thread = new Thread();
                    //while(true) {
                        Thread.sleep(6000);
                        String consRes = consumerConn.receiveRPC().toString();
                        printStream1.println(consRes);
                        printStream2.println(creditAgencyConn.receiveRPC());
                        printStream3.println(lenderConn.receiveRPC());
                        printStream4.println(bankQuoteCon.receiveRPC());
                        printStream5.println(bank1Con.receiveRPC());
                        printStream6.println(loanBrokerConn.receiveRPC());
                        //if (consRes.contains("done")) break;
                    //}
                } catch (IOException | OtpErlangExit | OtpAuthException | InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });


        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 400);
        setLocationRelativeTo(null);    // centers on screen

    }

    private void createConnections() throws IOException, OtpAuthException {

        OtpSelf self = new OtpSelf("me");
        consumerConn = self.connect(new OtpPeer("pidConsumer@developer"));
        loanBrokerConn = self.connect(new OtpPeer("pidLoanBroker@developer"));;
        creditAgencyConn = self.connect(new OtpPeer("pidCreditAgencyGateway@developer"));;
        lenderConn = self.connect(new OtpPeer("pidLenderGateway@developer"));;
        bankQuoteCon = self.connect(new OtpPeer("pidBankQuoteGateway@developer"));;
        bank1Con = self.connect(new OtpPeer("pidBank1@developer"));

    }

    private void sendingRPC(Integer times) throws IOException {
        consumerConn.sendRPC("quote", "runConsumerNode", new OtpErlangInt[]{new OtpErlangInt(times)});
        loanBrokerConn.sendRPC("quote", "runLoanBrokerNode", new OtpErlangList());
        creditAgencyConn.sendRPC("quote", "runCreditAgencyGateway", new OtpErlangList());
        lenderConn.sendRPC("quote", "runLenderGateway", new OtpErlangList());
        bankQuoteCon.sendRPC("quote", "runBankQuoteGateway", new OtpErlangList());
        bank1Con.sendRPC("quote", "runBank1Node", new OtpErlangList());
    }

    public static void main(String[] args) throws OtpErlangExit, IOException, OtpAuthException {
        TextAreaLogProgram pr = new TextAreaLogProgram();
        pr.setVisible(true);
        pr.framePanel.setVisible(true);
        pr.startButton.setVisible(true);

    }
}
