import com.ericsson.otp.erlang.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws OtpErlangExit, IOException, OtpAuthException {

        OtpSelf self = new OtpSelf("me");
        OtpPeer consumer = new OtpPeer("quote@developer");

        OtpConnection connection = self.connect(consumer);
        connection.sendRPC("quote","bank1",
                new OtpErlangList());
        OtpErlangObject received = connection.receiveRPC();
        System.out.println(received);
    }
}
