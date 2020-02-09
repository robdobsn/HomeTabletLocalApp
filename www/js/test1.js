var forceUpdate = function (callBack) {
    hasLatestUpdate(function (isUpdated, newVersion) {
        if (newVersion !== null) {
            var updateInProgress = CommunityApp.session.load("update-inprogress", true);
            if (updateInProgress != newVersion) {
                if (!isUpdated) {
                    CommunityApp.session.save("update-inprogress", newVersion, true);
                    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function (fileSystem) {
                        var apkFile = 'download/';
                        var permissions = cordova.plugins.permissions;
                        permissions.hasPermission(permissions.WRITE_EXTERNAL_STORAGE, function (status) {
                            if (!status.hasPermission) {
                                var errorCallback = function () {
                                    alert("Error: app requires storage permission");
                                    if (callBack && callBack !== null) {
                                        callBack();
                                    }
                                };
                                permissions.requestPermission(permissions.WRITE_EXTERNAL_STORAGE, function (status) {
                                    if (!status.hasPermission) errorCallback();
                                    else {
                                        downloadFile(fileSystem);
                                    }
                                }, errorCallback);
                            } else {
                                downloadFile(fileSystem);
                            }
                        }, null);
                        var downloadFile = function (fileSystem) {
                            var localPath = fileSystem.root.toURL() + 'download/new-android.apk',
                                fileTransfer = new FileTransfer();
                            fileTransfer.download(CommunityApp.configuration.appConfig.apkUrl, localPath, function (entry) {
                                window.plugins.webintent.startActivity({
                                    action: window.plugins.webintent.ACTION_VIEW,
                                    url: localPath,
                                    type: 'application/vnd.android.package-archive'
                                }, function () {}, function (e) {
                                    alert("Failed to update the app!");
                                    if (callBack && callBack !== null) {
                                        callBack();
                                    }
                                });
                            }, function (error) {
                                alert("Error downloading the latest updates! - error: " + JSON.stringify(error));
                                if (callBack && callBack !== null) {
                                    callBack();
                                }
                            });
                        };
                    }, function (evt) {
                        alert("Error preparing to download the latest updates! - Err - " + evt.target.error.code);
                        if (callBack && callBack !== null) {
                            callBack();
                        }
                    });
                } else {
                    if (callBack && callBack !== null) {
                        callBack();
                    }
                }
            } else {
                if (callBack && callBack !== null) {
                    callBack();
                }
            }
        } else {
            if (callBack && callBack !== null) {
                callBack();
            }
        }
    });
};
