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
  <title>A Cool Locator</title>
  <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.js" type="text/javascript"></script>
  <script type="text/javascript" src="https://maps.google.com/maps/api/js?v=3&key=AIzaSyDURrFYsoLPTgQL_XdajnZVDVzk5QZOQdU&libraries=places"></script>
  <script type="text/javascript">
    let map;
    let deviceId;
    var busMap;
    var restaurantsMap;
    window.onload = function(){
      initMap(40.4427355, -79.9451439);
      var device1 = document.getElementById("rushin_connect");
      device1.style.background = "red";
      device1.innerText = "Not connected";
      var device2 = document.getElementById("nishan_connect");
      device2.style.background = "red";
      device2.innerText = "Not connected";

    };
    function initMap(lat, long){
      const myLatLng = { lat: lat, lng: long };

      const map = new google.maps.Map(document.getElementById("map") , {
        zoom: 11,
        center: myLatLng
      });

      new google.maps.Marker({
        position: myLatLng,
        map
      });
    }
    function initBusMap(lat, long) {
      busMap = new google.maps.Map(document.getElementById("busMap"), {
        center: {lat: lat, lng: long},
        zoom: 11
      });

      var requestBusMap = {
        location: {lat: lat, lng: long},
        radius: 8047,
        types: ['bus_station']
      };

      var serviceBus = new google.maps.places.PlacesService(busMap);
      serviceBus.nearbySearch(requestBusMap, callbackBus);

    }
    function initResMap(lat, long){
      restaurantsMap = new google.maps.Map(document.getElementById("restMap"), {
        center: {lat: lat, lng: long},
        zoom: 11
      });
      var requestRestMap = {
        location: {lat: lat, lng: long},
        radius: 8047,
        types: ['restaurant']
      };
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
      client.subscribe("location/connection/project4");
    }
    // called when the client loses its connection
    function onConnectionLost(responseObject) {
      if (responseObject.errorCode !== 0) {
        console.log("onConnectionLost:"+responseObject.errorMessage);
      }
    }
    var locationList = {"nishan": "", "rushin": "40.4291584,-79.9309824"};
    // called when a message arrives, display it in the console

    function onMessageArrived(message) {
      var messages = message.payloadString.split(",");
      console.log("message arrived: " + message);
      deviceId = messages[1];
      document.getElementById("deviceId").innerHTML = "Device: " + deviceId;


      var id = "";
      var user = "";
      if(messages[1].trim() === "1c001f000c47343438323536"){
        id = "nishan_connect";
        user = "nishan";
      }else if(messages[1].trim() === "26001a000d47373334323233"){
        id = "rushin_connect";
        user = "rushin";
      }else{
        user = "unknown";
      }
      var connect_div = document.getElementById(id);
      if(messages[0].trim() === "location"){
        locationList[user] = messages[2] + "," + messages[3];
        var lat = parseFloat(messages[2]);
        var long = parseFloat(messages[3]);
        console.log(lat, long);
        initMap(lat, long);
        console.log("location: " , lat +"," + long);

      }else if(messages[0].trim() === "connection"){
        if(messages[2].trim() === "0"){
          //not connected
          connect_div.style.background = "red";
          connect_div.innerText = "Not connected";
        }else if(messages[2].trim() === "1"){
          //connected
          connect_div.style.background = "green";
          connect_div.innerText = "Connected";
        }
      }

      if(locationList["nishan"] !== "" && locationList["rushin"] !== ""){
        var nishanLoc = locationList["nishan"].split(",");
        var rushinLoc = locationList["rushin"].split(",");
        var loc1 = new google.maps.LatLng(nishanLoc[0], nishanLoc[1]);
        var loc2 = new google.maps.LatLng(rushinLoc[0], rushinLoc[1]);

        var origin = user === "nishan" ? loc1 : loc2;
        var destination = user === "nishan" ? loc2 : loc1;
        console.log("origin: " , origin);
        console.log("destination: " , destination);
        var service = new google.maps.DistanceMatrixService();
        service.getDistanceMatrix(
                {
                  origins: [origin],
                  destinations: [destination],
                  travelMode: 'DRIVING'
                }, callback);


      }
    }

    function callback(response, status) {
      // See Parsing the Results for
      // the basics of a callback function.
      if (status === google.maps.DistanceMatrixStatus.OK) {
        console.log("distance response: ", response);
        // var json = JSON.parse(response);
        var distance = response.rows[0].elements[0].distance.text; // get the diatance between two locations
        document.getElementById("distance").innerText = "Distance: " + distance;
      } else {
        console.log('Error:', status);
      }
    }

    function nearBus(name){
      var loc = locationList[name].split(",");
      initBusMap(parseFloat(loc[0]), parseFloat(loc[1]));
    }
    function nearRestaurant(name){
      var loc = locationList[name].split(",");
      initResMap(parseFloat(loc[0]), parseFloat(loc[1]));
    }
  </script>
  <style>
    #container {height: 100%; width:100%;}
    #left, #middle, #right {
      display: inline-block;
      *display: inline;
      zoom: 1;
      vertical-align: top;
      margin-left: 5px;
    }
    #left {width: 25%; }
    #middle {width: 25%; }
    #right {width: 40%;}
    .connect {
      height: 70px;
      width: 70px;
      display: inline-block;
      *display: inline;
      zoom: 1;
      vertical-align: top;
      margin-left: 5px;
    }
  </style>
</head>
<body>
<h1 id="deviceId"> Device: </h1>
<div id="map" style="height:300px; width:600px"></div>
<div id="container">
  <div id="left">
    <h3> Nearby Bus Stations </h3>
    <div id="busMap" style="height:300px; width:300px"></div>
  </div>
  <div id="middle">
    <h3> Nearby Restaurants </h3>
    <div id="restMap" style="height:300px; width:300px"></div>
  </div>
  <div id="right">
    <div style="height: 100%; width:100%;">
      <div style="display: inline-block; *display: inline;width: 50%">
    <div>Rushin's Photon<div>
      <div id="rushin_connect" class="connect"></div>
      <div><button onclick="nearRestaurant('rushin')">Restaurant near him/her</button></div>
      <button onclick="nearBus('rushin')">Bus stop near him/her</button>
    </div>
      <div style="display: inline-block; *display: inline;width: 50%">
    <div>Nishan's Photon<div>
      <div id="nishan_connect" class="connect"></div>
      <button onclick="nearRestaurant('nishan')">Restaurant near him/her</button>
      <button onclick="nearBus('nishan')">Bus stop near him/her</button>
    </div>
    <div id="distance">Distance: </div>
  </div>

</div>
</body>
</html>