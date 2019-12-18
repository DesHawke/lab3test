import com.ericsson.otp.erlang.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws OtpErlangExit, IOException, OtpAuthException {

        OtpSelf self = new OtpSelf("me");
        OtpPeer consumer = new OtpPeer("remote@127.0.0.1");

        OtpConnection connection = self.connect(consumer);
        connection.sendRPC("erlang","date",
                new OtpErlangList());
        OtpErlangObject received = connection.receiveRPC();
        System.out.println(received);
    }
}
