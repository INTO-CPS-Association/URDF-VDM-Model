/*******************************************************************************
 *
 *	Copyright (c) 2023 Nick Battle.
 *
 *	Author: Nick Battle
 *
 *	This file is part of VDMJ.
 *
 *	VDMJ is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	VDMJ is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with VDMJ.  If not, see <http://www.gnu.org/licenses/>.
 *	SPDX-License-Identifier: GPL-3.0-or-later
 *
 ******************************************************************************/
package xmlreader;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.charset.Charset;

import com.fujitsu.vdmj.lex.ExternalFormatReader;

import xsd2vdm.Xsd2Raw;

/**
 * A class to read raw XML and return VDM-SL data
 */
public class XMLReader implements ExternalFormatReader
{
	@Override
	public char[] getText(File file, Charset charset) throws IOException
	{
		try
		{
			OutputStream os = new ByteArrayOutputStream();
			PrintStream ps = new PrintStream(os);
			
			Xsd2Raw converter = new Xsd2Raw(file, ps);
			converter.process();
			
			String s = os.toString();
			return s.toCharArray();
		}
		catch (Throwable th)
		{
			throw new IOException(th.getMessage());
		}
	}

	/**
	 * Test the reader
	 */
	public static void main(String[] args) throws IOException
	{
		File file = new File(args[0]);
		XMLReader reader = new XMLReader();
		char[] a = reader.getText(file, null);
		System.out.println(new String(a));
	}
}
