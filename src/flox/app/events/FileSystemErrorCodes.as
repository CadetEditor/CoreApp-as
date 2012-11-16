// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.events
{
	public class FileSystemErrorCodes
	{
		public static const WRITE_FILE_ERROR					:int = 0;
		public static const READ_FILE_ERROR						:int = 1;
		public static const DELETE_FILE_ERROR					:int = 2;
		public static const CREATE_DIRECTORY_ERROR				:int = 3;
		public static const NOT_A_DIRECTORY						:int = 4;
		public static const GET_DIRECTORY_CONTENTS_ERROR		:int = 5;
		public static const DOES_FILE_EXIST_ERROR				:int = 6;
		
		public static const DIRECTORY_DOES_NOT_EXIST			:int = 7;
		public static const FILE_DOES_NOT_EXIST					:int = 8;
		public static const DIRECTORY_ALREADY_EXISTS			:int = 9;
		
		public static const SET_METADATA_ERROR					:int = 10;
		public static const GET_METADATA_ERROR					:int = 11;
		public static const DELETE_METADATA_ERROR				:int = 12;
		
		public static const GENERIC_ERROR						:int = 13;
		
		public static const OPERATION_NOT_SUPPORTED				:int = 14;
		
	}
}