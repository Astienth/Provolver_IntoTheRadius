using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Net.Sockets;
using System.Net;
using System.Text;
using System;

namespace Provolver_IntoTheRadius
{
    public class Engine
    {
        public bool serverStop = false;
        public Action<string> UpdateProgress;

        public void initEngine()
        {
            try
            {
                this.initSyncAsync();
                Thread Udp = new Thread(() => this.createUDPListener());
                Udp.Start();
            } catch (Exception ex)
            {
                this.UpdateProgress(ex.Message);
            }
        }
        public async Task initSyncAsync()
        {
            await ForceTubeVRInterface.InitAsync(true);
            Thread.Sleep(10000);
        }

        public void createUDPListener()
        {
            try
            {
                int recv;
                byte[] data = new byte[1024];
                IPEndPoint ipep = new IPEndPoint(IPAddress.Loopback, 5020);

                Socket newsock = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

                newsock.Bind(ipep);
                this.UpdateProgress("Ready, waiting for game events");

                IPEndPoint sender = new IPEndPoint(IPAddress.Any, 0);
                EndPoint Remote = (EndPoint)(sender);

                while (!serverStop)
                {
                    data = new byte[1024];
                    recv = newsock.ReceiveFrom(data, ref Remote);

                    this.UpdateProgress("Message received from " + Remote.ToString());
                    string message = Encoding.ASCII.GetString(data, 0, recv);
                    this.UpdateProgress(message);
                    this.HandleMessage(message);
                }
            } catch (Exception ex)
            {
                this.UpdateProgress(ex.Message);
            }
        }
    
        public void HandleMessage(string message)
        {
            // parse message
            String[] messageParams = message.Split(',');

            switch (messageParams[0])
            {
                case "kick":
                    ForceTubeVRInterface.Kick((byte)Convert.ToInt32(messageParams[1]), ForceTubeVRChannel.all);
                    break;
                case "rumble":
                    ForceTubeVRInterface.Rumble(
                        (byte)Convert.ToInt32(messageParams[2]),
                        (float)Convert.ToDouble(messageParams[3]), 
                        ForceTubeVRChannel.all
                    );
                    break;
                case "shoot":
                    ForceTubeVRInterface.Shoot(
                        (byte)Convert.ToInt32(messageParams[1]),
                        (byte)Convert.ToInt32(messageParams[2]),
                        (float)Convert.ToDouble(messageParams[3]),
                        ForceTubeVRChannel.all
                    );
                    break;
                default:
                    ForceTubeVRInterface.Kick((byte)Convert.ToInt32(messageParams[1]), ForceTubeVRChannel.all);
                    break;
            }
        }
    }
}
