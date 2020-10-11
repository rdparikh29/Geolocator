<%--
  Created by IntelliJ IDEA.
  User: rushin
  Date: 10/10/20
  Time: 11:52 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>$Title$</title>
    <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.js" type="text/javascript"></script>
    <script type="text/javascript" src="https://maps.google.com/maps/api/js?v=3&key=AIzaSyDURrFYsoLPTgQL_XdajnZVDVzk5QZOQdU&libraries=places"></script>
    <script type="text/javascript">
      let map;
      let deviceId;
      function initMap(lat, long) {
        busMap = new google.maps.Map(document.getElementById("busMap"), {
          center: {lat: lat, lng: long},
          zoom: 11,
        });

        restaurantsMap = new google.maps.Map(document.getElementById("restMap"), {
          center: {lat: lat, lng: long},
          zoom: 11,
        });

        var requestBusMap = {
          location: {lat: lat, lng: long},
          radius: 8047,
          types: ['bus_station']
        };

        var requestRestMap = {
          location: {lat: lat, lng: long},
          radius: 8047,
          types: ['restaurant']
        };

        var serviceBus = new google.maps.places.PlacesService(busMap);
        serviceBus.nearbySearch(requestBusMap, callbackBus);

        var serviceRest = new google.maps.places.PlacesService(restaurantsMap);
        serviceRest.nearbySearch(requestRestMap, callbackRest);
      }

      function callbackBus(results, status) {
        if(status === google.maps.places.PlacesServiceStatus.OK) {
          for (var i = 0; i < results.length; i++) {
            createMarkerBus(results[i]);
          }
        }
      }

      function callbackRest(results, status) {
        if(status === google.maps.places.PlacesServiceStatus.OK) {
          for (var i = 0; i < results.length; i++) {
            createMarkerRest(results[i]);
          }
        }
      }

      function createMarkerBus(place) {
        var placeLoc = place.geometry.location;
        var marker = new google.maps.Marker({
          map: busMap,
          position: placeLoc
        })
      }

      function createMarkerRest(place) {
        var placeLoc = place.geometry.location;
        var marker = new google.maps.Marker({
          map: restaurantsMap,
          position: placeLoc
        })
      }

      // Create a client instance
      client = new Paho.MQTT.Client("broker.hivemq.com", Number(8000),  "project4_subscriber"); // Websocket running on port 8000

      // set callback handlers
      client.onConnectionLost = onConnectionLost;
      client.onMessageArrived = onMessageArrived;

      // connect the client
      client.connect({onSuccess:onConnect});


      // called when the client connects
      function onConnect() {
        // Once a connection has been made, log it to the console.
        console.log("onConnect Subscriber");
        client.subscribe("location/myLocation/project4");
      }

      // called when the client loses its connection
      function onConnectionLost(responseObject) {
        if (responseObject.errorCode !== 0) {
          console.log("onConnectionLost:"+responseObject.errorMessage);
        }
      }

      // called when a message arrives, display it in the console
      function onMessageArrived(message) {
        var messages = message.payloadString.split(",");
        deviceId = messages[0];
        document.getElementById("deviceId").innerHTML = "Photon Id: " + deviceId;
        var lat = parseFloat(messages[1]);
        var long = parseFloat(messages[2]);
        console.log(lat, long);
        initMap(lat, long);

      }


    </script>
  </head>
  <body>
    <h1 id="deviceId"> Device: </h1>
    <h3> Nearby Bus Stations </h3>
    <div id="busMap" style="height:300px; width:500px"></div>
    <h3> Nearby Restaurants </h3>
    <div id="restMap" style="height:300px; width:500px"></div>
  </body>
</html>
