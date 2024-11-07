from awscrt import mqtt, http
from awsiot import mqtt_connection_builder
from dotenv import load_dotenv
import os
import sys
import threading
import time
import json
import time


class MQTT:

    def __init__(self):
        self._receivedCount = 0
        self._setCount = 10
        self._receivedAllEvent = threading.Event()

        self._endpoint = None
        self._port = None
        self._certFilepath = None
        self._priKeyFilepath = None
        self._caFilepath = None
        self._clientId = None

        self._messageTopic = []

        self._mqttConnection = None
        self._connectFuture = None

        self._subscribeFuture = []
        self._packetId = []
        self._subscribeResult = []

        self._disconnectFuture = None

    # Callback when connection is accidentally lost.
    def _onConnectionInterrupted(self, connection, error, **kwargs):
        print("Connection interrupted. error: {}".format(error))


    # Callback when an interrupted connection is re-established.
    def _onConnectionResumed(self, connection, returnCode, sessionPresent, **kwargs):
        print("Connection resumed. return code: {} session present: {}".format(returnCode, sessionPresent))

        if returnCode == mqtt.ConnectReturnCode.ACCEPTED and not sessionPresent:
            print("Session did not persist. Resubscribing to existing topics...")
            resubscribeFuture, _ = connection.resubscribe_existing_topics()

            # Cannot synchronously wait for resubscribe result because we're on the connection's event-loop thread,
            # evaluate result with a callback instead.
            resubscribeFuture.add_done_callback(onResubscribeComplete)


    def _onResubscribeComplete(self, resubscribeFuture):
        resubscribeResults = resubscribeFuture.result()
        print("Resubscribe results: {}".format(resubscribeResults))

        for topic, qos in resubscribeResults['topics']:
            if qos is None:
                sys.exit("Server rejected resubscribe to topic: {}".format(topic))


    # Callback when the subscribed topic receives a message
    def _onMessageReceived(self, topic, payload, dup, qos, retain, **kwargs):
        print("Received message from topic '{}': {}".format(topic, payload))
        
        #################################################
        ############# Message received ##################
        #################################################

    # Callback when the connection successfully connects
    def _onConnectionSuccess(self, connection, callback_data):
        assert isinstance(callback_data, mqtt.OnConnectionSuccessData)
        print("Connection Successful with return code: {} session present: {}".format(callback_data.return_code, callback_data.session_present))

    # Callback when a connection attempt fails
    def _onConnectionFailure(self, connection, callback_data):
        assert isinstance(callback_data, mqtt.OnConnectionFailureData)
        print("Connection failed with error code: {}".format(callback_data.error))


    # Callback when a connection has been disconnected or shutdown successfully
    def _onConnectionClosed(self, connection, callback_data):
        print("Connection closed")


class MQTTBuilder(MQTT):

    def __init__(self):
        MQTT.__init__(self)
    
    # setting parameters
    def setEndpoint(self, endpoint):
        self._endpoint = endpoint
        return self
    
    def setPort(self, port = 8883):
        self._port = port
        return self

    def setCertFilepath(self, certFilepath):
        self._certFilepath = certFilepath
        return self

    def setPriKeyFilepath(self, priKeyFilepath):
        self._priKeyFilepath = priKeyFilepath
        return self

    def setCaFilepath(self, caFilepath):
        self._caFilepath = caFilepath
        return self

    def setClientId(self, clientId = 'Jetson_Nano'):
        self._clientId = clientId
        return self
    
    # Create a MQTT connection from parameters
    def setConnection(self):
        self._mqttConnection = mqtt_connection_builder.mtls_from_path(
            endpoint = self._endpoint,
            port = self._port,
            cert_filepath = self._certFilepath,
            pri_key_filepath = self._priKeyFilepath,
            ca_filepath = self._caFilepath,
            on_connection_interrupted = self._onConnectionInterrupted,
            on_connection_resumed = self._onConnectionResumed,
            client_id = self._clientId,
            clean_session = False,
            keep_alive_secs = 60,
            http_proxy_options = None,
            on_connection_success = self._onConnectionSuccess,
            on_connection_failure = self._onConnectionFailure,
            on_connection_closed = self._onConnectionClosed)

        self._connectFuture = self._mqttConnection.connect()

        # Future.result() waits until a result is available
        self._connectFuture.result()
        print("Connected!")

        return self

    # # add topics for subscribing
    # def addTopic(self, messageTopic):
    #     self._messageTopic.append(messageTopic)

    #     print("Subscribing to topic '{}'...".format(messageTopic))
    #     subscribeFuture, packetId = self._mqttConnection.subscribe(
    #         topic = messageTopic,
    #         qos = mqtt.QoS.AT_LEAST_ONCE,
    #         callback = self._onMessageReceived)

    #     self._subscribeFuture.append(subscribeFuture)
    #     self._packetId.append(packetId)

    #     subscribeResult = subscribeFuture.result()
    #     self._subscribeResult.append(subscribeResult)
    #     print("Subscribed with {}".format(str(subscribeResult['qos'])))

    #     return self

    # ==================================================================================
    # def addTopic(self, messageTopic):
    #     try:
    #         # 연결 상태 확인
    #         if not self._mqttConnection:
    #             raise Exception("MQTT connection is not established")

    #         self._messageTopic.append(messageTopic)

    #         print(f"Subscribing to topic '{messageTopic}'...")
            
    #         # QoS 레벨을 0으로 낮춤
    #         subscribeFuture, packetId = self._mqttConnection.subscribe(
    #             topic=messageTopic,
    #             qos=mqtt.QoS.AT_MOST_ONCE,
    #             callback=self._onMessageReceived)

    #         self._subscribeFuture.append(subscribeFuture)
    #         self._packetId.append(packetId)

    #         # 타임아웃 설정
    #         try:
    #             subscribeResult = subscribeFuture.result(timeout=5)
    #             if 'qos' not in subscribeResult:
    #                 raise Exception("Subscription failed - no QoS in result")
                
    #             self._subscribeResult.append(subscribeResult)
    #             print(f"Successfully subscribed to {messageTopic} with QoS: {str(subscribeResult['qos'])}")
                
    #             # 구독 확인을 위한 대기
    #             time.sleep(1)
                
    #             return self

    #         except TimeoutError:
    #             print(f"Subscription to {messageTopic} timed out")
    #             raise
    #         except Exception as e:
    #             print(f"Subscription error: {str(e)}")
    #             raise

    #     except Exception as e:
    #         print(f"Failed to add topic {messageTopic}: {str(e)}")
    #         # 실패한 토픽 제거
    #         if messageTopic in self._messageTopic:
    #             self._messageTopic.remove(messageTopic)
    #         raise

    #=================================================================

    # 여러 개 구독하는 케이스면 이런 식으로 메서드 수정해야 함.
    def addTopic(self, TOPICS):
        for messageTopic in TOPICS:
            self._messageTopic.append(messageTopic)

            print("Subscribing to topic '{}'...".format(messageTopic))
            subscribeFuture, packetId = self._mqttConnection.subscribe(
                topic = messageTopic,
                qos = mqtt.QoS.AT_LEAST_ONCE,
                callback = self._onMessageReceived)

            self._subscribeFuture.append(subscribeFuture)
            self._packetId.append(packetId)

            subscribeResult = subscribeFuture.result()
            self._subscribeResult.append(subscribeResult)
            print("Subscribed with {}".format(str(subscribeResult['qos'])))
        return self

    # Publish MQTT message
    def publishMessage(self, topic, messageString):
        message = "{}".format(messageString)
        print("Publishing message to topic '{}': {}".format(topic, messageString))
        message_json = json.dumps(messageString)
        self._mqttConnection.publish(
            topic=topic,
            payload=message_json,
            qos=mqtt.QoS.AT_LEAST_ONCE)

    # Disconnecting from AWS IoT
    def setDisconnection(self):
        print("Disconnecting...")
        self._disconnectFuture = self._mqttConnection.disconnect()
        self._disconnectFuture.result()
        print("Disconnected!")

        return self



if __name__ == '__main__':

    load_dotenv()

    END_POINT = os.environ.get('END_POINT')
    CERT_FILE_PATH = os.environ.get('CERT_FILE_PATH')
    CA_FILE_PATH = os.environ.get('CA_FILE_PATH')
    PRI_KEY_FILE_PATH = os.environ.get('PRI_KEY_FILE_PATH')

    print("CertPath:{}".format(CERT_FILE_PATH))
    # print(f'End Point : {END_POINT}')
    print(f'CA PATH : {CA_FILE_PATH}')
    print(f'PRI_KEY : {PRI_KEY_FILE_PATH}')
    
    TOPICs = ['mqtt_test','camera','pressed',]
    
    print(TOPICs)

    mqttBuild = MQTTBuilder() \
                .setEndpoint(END_POINT) \
                .setPort() \
                .setCertFilepath(CERT_FILE_PATH) \
                .setCaFilepath(CA_FILE_PATH) \
                .setPriKeyFilepath(PRI_KEY_FILE_PATH) \
                .setClientId() \
                .setConnection() \
                .addTopic(TOPICs)
    
    mqttBuild.publishMessage('mqtt_test','Hello AWS!!')
    print("@@@@@@@@@published@@@@@@@@@")

    while True:
        time.sleep(1)

    mqttBuild.setDisconnection()

    