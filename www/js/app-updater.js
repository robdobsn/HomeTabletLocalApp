// Generated by CoffeeScript 2.7.0
(function() {
  App.AppUpdater = class AppUpdater {
    constructor(app, updateURL) {
      this.app = app;
      this.updateURL = updateURL;
      console.log("Updater set " + this.updateURL);
    }

    appUpdate() {
      console.log("Use web update");
      return window.plugins.webintent.startActivity({
        action: window.plugins.webintent.ACTION_VIEW,
        // url: @updateURL + "/WallTabletApp.apk",
        url: "http://192.168.86.247:5076/deployota/WallTabletApp/index.html"
      // url: ""
      // url: e.target.localURL,
      // url: 'geo:0,0?q=8 Dick Place, EH9 2JL',
      // url: 'cdvfile://localhost/persistent/WallTabletApp.apk', 
      // url: 'file://localhost/persistent/WallTabletApp.apk', 
      // url: 'file://storage/emulated/0/WallTabletApp.apk',
      // type: 'application/vnd.android.package-archive'
      }, function() {}, function() {
        return alert('Failed to open URL via Android Intent');
      });
    }

  };

  //     console.log "appUpdate"
//     $.ajax 
//         url: @updateURL + "/WallTabletApp/vers.json"
//         type: 'GET'
//         contentType: "application/json"
//         success: (data, status, response) =>
//             console.log "appUpdate got response " + JSON.stringify(data)
//             if @app.VERSION < data.version
//                 console.log "appUpdate required"
//                 @performUpdate(@updateURL + "/WallTabletApp/" + data.filename)
//             else
//                 console.log "appUpdate not required"
//             return
//         error: (jqXHR, textStatus, errorThrown) =>
//             console.log "appUpdate get vers.json failed: " + textStatus + " " + errorThrown
//             return

  // performUpdate: (@appFileDownloadURL) ->
//     console.log "performUpdate"
//     window.requestFileSystem LocalFileSystem.PERSISTENT, 0, (fileSystem) =>
//         @downloadFile fileSystem
//         # apkFile = 'download/'
//         # permissions = cordova.plugins.permissions
//         # permissions.hasPermission permissions.WRITE_EXTERNAL_STORAGE, ((status) ->
//         #     if !status.hasPermission
//         #         errorCallback = ->
//         #             alert 'Error: app requires storage permission'
//         #             if callBack and callBack != null
//         #                 callBack()
//         #             return
//         #         permissions.requestPermission permissions.WRITE_EXTERNAL_STORAGE, ((status) ->
//         #             if !status.hasPermission
//         #                 errorCallback()
//         #             else
//         #                 @downloadFile fileSystem
//         #             return
//         #         ), errorCallback
//         #     else
//         #         @downloadFile fileSystem
//         #         return
//         # )
//         , null,
//         (evt) ->
//             alert 'Error preparing to download the latest updates! - Err - ' + evt.target.error.code
//             if callBack and callBack != null
//                 callBack()
//             return

  // downloadFile: (fileSystem) ->
//     localPath = fileSystem.root.toURL() + 'download/WallTabletApp.apk'

  //     console.log("Download file from URL " + @appFileDownloadURL)

  //     xhr = new XMLHttpRequest()
//     xhr.open 'GET', @appFileDownloadURL, true
//     xhr.responseType = 'blob'
//     xhr.onload = () =>
//         console.log("File download status " + xhr.status)
//         if xhr.status == 200
//             console.log("Got file")
//             blob = new Blob([this.response], { type: 'application/vnd.android.package-archive' })
//             @doSaveFile(fileSystem.root, blob, "WallTabletApp.apk")
//     xhr.send()

  //     # fileTransfer = new FileTransfer
//     # fileTransfer.download @appFileDownloadURL, localPath, (entry) ->
//     #     window.plugins.webintent.startActivity (
//     #         {
//     #             action: window.plugins.webintent.ACTION_VIEW
//     #             url: localPath
//     #             type: 'application/vnd.android.package-archive'
//     #         }
//     #         () -> 
//     #             console.log("download started")
//     #             return
//     #         (e) ->
//     #             alert 'Failed to update the app!'
//     #             if callBack and callBack != null
//     #                 callBack()
//     #             return
//     #     ),
//     #     (error) ->
//     #         alert 'Error downloading the latest updates! - error: ' + JSON.stringify(error)
//     #         if callBack and callBack != null
//     #             callBack()
//     #         return

  // doSaveFile: (dirEntry, fileData, fileName) ->
//     console.log("Save file " + fileName)
//     dirEntry.getFile fileName, { create: true, exclusive: false }, (fileEntry) =>
//         @writeFile(fileEntry, fileData);
//     , @onErrorCreateFile

  // onErrorCreateFile: (e) ->
//     console.log("Failed to create file " + e)

  // writeFile: (fileEntry, dataObj, isAppend) ->
//     # Create a FileWriter object for our FileEntry (log.txt).
//     fileEntry.createWriter (fileWriter) =>
//         # fileWriter.onwriteend = () ->
//         #     console.log("Successful file write...")
//         #     if dataObj.type == "application/vnd.android.package-archive"
//         #         readBinaryFile(fileEntry);
//         #     else
//         #         readFile(fileEntry);
//         fileWriter.onerror = (e) ->
//             console.log("Failed file write: " + e.toString())

  //         fileWriter.onwriteend = (e) =>
//             console.log('Write completed filename ' + e.target.localURL)
//             # window.plugins.webintent.startActivity (
//             #     {
//             #         action: window.plugins.webintent.ACTION_VIEW
//             #         url: e.target.localURL
//             #         type: 'application/vnd.android.package-archive'
//             #     }
//             #     (e) -> 
//             #         console.log("success")
//             #         return
//             #     (e) ->
//             #         console.log 'Failed to update the app!'
//             #         # if callBack and callBack != null
//             #         #     callBack()
//             #         # return
//             # )
//             @checkIfFileExists(e.target.localURL)
//             @checkIfFileExists('cdvfile://localhost/persistent/WallTabletApp.apk')
//             @checkIfFileExists('file://localhost/persistent/WallTabletApp.apk')
//             @checkIfFileExists('file://storage/emulated/0/WallTabletApp.apk')

  //             window.plugins.webintent.startActivity({
//                 action: window.plugins.webintent.ACTION_VIEW,
//                 url: e.target.localURL,
//                 # url: 'geo:0,0?q=8 Dick Place, EH9 2JL',
//                 # url: 'cdvfile://localhost/persistent/WallTabletApp.apk', 
//                 # url: 'file://localhost/persistent/WallTabletApp.apk', 
//                 # url: 'file://storage/emulated/0/WallTabletApp.apk',
//                 type: 'application/vnd.android.package-archive'}
//                 () -> ,
//                 () -> alert('Failed to open URL via Android Intent')
//                 )
//         fileWriter.write(dataObj)

  // checkIfFileExists: (@path) ->
//     window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, (fileSystem) =>
//         fileSystem.root.getFile(path, { create: false }, @fileExists, @fileDoesNotExist)
//     , @getFSFail)

  // fileExists: (fileEntry) ->
//     alert("File " + fileEntry.fullPath + " exists!")

  // fileDoesNotExist: () =>
//     alert("file does not exist" + @path);

  // getFSFail: (evt) ->
//     console.log(evt.target.error.code)

}).call(this);

//# sourceMappingURL=app-updater.js.map
