const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require('firebase-admin');
admin.initializeApp();

exports.correctPeopleReady = functions.database.ref('/Lobbies/{lobbyID}/peopleReady').onUpdate((change,context) => {

    //get the value
    let value = change.after._data

    //check if there is a mistake with the number of people ready
    if (value < 0) {
        return change.after.ref.parent.child('peopleReady').set(0) //correct
    }

      return null  //no mistake, do nothing
    
        
})

//send a notification when someone gets passed on the leaderboard
exports.leaderBoardNotification = functions.https.onCall((data,context) => {

    var token = data.token
    var name = data.name
    var mode = data.mode

    const payload = {

        notification: {
    
    
          body: name + " has beat your score in " + mode + ". Get back in there and show them who's boss!",
          badge: "1",
          sound: "default"
    
        }
    
      };

      //send to device
    return admin.messaging().sendToTopic(token,payload);

})

//delete a lobby when everyone leaves it.
exports.deleteEmptyLobby = functions.database.ref('/Lobbies/{lobbyID}/Players').onDelete((snapshot,context) => {

                   
       
        console.log(snapshot.ref.parent.key)
          return snapshot.ref.parent.remove()

       
})



