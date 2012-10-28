/**
 * Constructor
 */
function TNDownloadManager() {
};

/** 
****** url: download link
****** destFileName: name of file that will be saved
****** destPath: destination path
****** userInfo: it should be a dictionary(key/value) object, it stores informations about the file want to download.Could be NULL
****** Example: function("http://www.fileden.com/files/2008/6/1/1939901/sample.mp4", "sample.mp4", destPath, {fileID: 1234})
**/
TNDownloadManager.prototype.downloadFile = function(url, destFileName, destPath, userInfo) {
    cordova.exec(null, null, "TNDownloadManager", "downloadFile", [url, destFileName, destPath, userInfo]);
};

/** 
****** Use this function to track the progress of a download
****** received: number of received bytes
****** total: File size
****** Example: function(received, total, userInfo) {}
**/
TNDownloadManager.prototype.downloadingProgress = null;

/** 
****** Callback functions when download finished (Success or Failure)
****** Example: function(userInfo) {}
**/
TNDownloadManager.prototype.downloadSuccessfull = null;
TNDownloadManager.prototype.downloadFailed = null;

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.tnDownloadManager) {
    window.plugins.tnDownloadManager = new TNDownloadManager();
}