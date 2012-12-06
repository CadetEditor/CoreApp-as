package flox.app.core.managers.fileSystemProviders
{
	import flox.app.entities.URI;

	public interface ILocalFileSystemProvider extends IFileSystemProvider
	{
		function get rootDirectoryURI():URI
		function get defaultDirectoryURI():URI
	}
}