package core.app.core.managers.fileSystemProviders
{
	import core.app.entities.URI;

	public interface ILocalFileSystemProvider extends IFileSystemProvider
	{
		function get rootDirectoryURI():URI;
		function get defaultDirectoryURI():URI;
	}
}