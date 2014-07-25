/// <summary>
/// 
/// SplitString_Multi( ... )
/// String splitting code copied from
/// http://sqlblog.com/blogs/adam_machanic/archive/2009/04/28/sqlclr-string-splitting-part-2-even-faster-even-more-scalable.aspx
/// 
/// 28/02/2014  MC  New
/// 
/// 
/// cleanString( ... )
/// Remove HTML mark up and other non-human data from string
/// Thanks to Erland Sommarskog for his typically insightful explanation of CLR
/// http://www.sommarskog.se/arrays-in-sql-2005.html#CLR
/// 
/// Note that ToString() returns string value; (string) cast returns string object
/// 
/// 16/06/2014  TW  New
/// 
/// </summary>

using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Net;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(
       IsDeterministic = true
       )
    ]
    [return: SqlFacet(MaxSize = -1)]
    public static SqlString cleanString(
        [SqlFacet(MaxSize = -1)]
        SqlString dirtyString
        )
    {
        // Check whether dirtyString is either null or empty
        if (dirtyString.IsNull)
        {
            return SqlString.Null;
        }
        if (dirtyString.ToString() == "")
        {
            return new SqlString("");
        }

        String cleanedString = (string) dirtyString;

        // Clean specific problems: strings starting with "&#711;"
        if (cleanedString.Length >= 6)
            {
            if (cleanedString.Substring(0, 6) == @"&#711;")
            {
                cleanedString = cleanedString.Remove(0, 6);
            }
        }

        // Clean specific problems: strings starting with "&#271;&#380;&#733;"
        if (cleanedString.Length >= 18)
        {
            if (cleanedString.Substring(0, 18) == @"&#271;&#380;&#733;")
            {
                cleanedString = cleanedString.Remove(0, 18);
            }
        }

        // Clean specific problems: strings starting with "* ", "- ", "? "
        if (cleanedString.Length >= 2)
        {
            if (cleanedString.Substring(0, 2) == @"* ")
            {
                cleanedString = cleanedString.Remove(0, 2);
            }
            if (cleanedString.Substring(0, 2) == @"- ")
            {
                cleanedString = cleanedString.Remove(0, 2);
            }
            if (cleanedString.Substring(0, 2) == @"? ")
            {
                cleanedString = cleanedString.Remove(0, 2);
            }
        }

        // Clean specific problems: "&bull;" bullet point character
        cleanedString = cleanedString.Replace(@"&bull;", " ");

        // Clean specific problems: multiple *, +, = characters
        Match match = Regex.Match(cleanedString, @"\*{2,}");
        if (match.Success)
        {
            cleanedString = Regex.Replace(cleanedString, @"\*{2,}", " ");
        }
        match = Regex.Match(cleanedString, @"\+{2,}");
        if (match.Success)
        {
            cleanedString = Regex.Replace(cleanedString, @"\+{2,}", " ");
        }
        match = Regex.Match(cleanedString, @"\={2,}");
        if (match.Success)
        {
            cleanedString = Regex.Replace(cleanedString, @"\={2,}", " ");
        }

        // Clean specific problems: underscore characters
        cleanedString = cleanedString.Replace(@"_", " ");

        // HtmlDecode
        // Decode twice to decode data such as "&amp;#39;"
        cleanedString = WebUtility.HtmlDecode(cleanedString);
        cleanedString = WebUtility.HtmlDecode(cleanedString);

        // Strip HTML tags
        cleanedString = StripTagsCharArray(cleanedString);

        // Replace multiple spaces - better to replace whitespace, see below
        // cleanedString = Regex.Replace(cleanedString, @"[ ]{2,}", @" ");

        // Replace runs of whitespace with a single space character
        cleanedString = Regex.Replace(cleanedString, @"\s+", @" ");

        // Finally a left trim
        cleanedString = cleanedString.TrimStart(' ');

        return new SqlString(cleanedString);
    }

    public static string StripTagsCharArray(string source)
    {
        char[] array = new char[source.Length];
        int arrayIndex = 0;
        bool inside = false;
        for (int i = 0; i < source.Length; i++)
        {
            char let = source[i];
            if (let == '<')
            {
                inside = true;
                continue;
            }
            if (let == '>')
            {
                inside = false;
                continue;
            }
            if (!inside)
            {
                array[arrayIndex] = let;
                arrayIndex++;
            }
        }
        return new string(array, 0, arrayIndex);
    }

    [Microsoft.SqlServer.Server.SqlFunction(
       FillRowMethodName = "FillRow_Multi",
       TableDefinition = "item nvarchar(4000)"
       )
    ]
    public static IEnumerator SplitString_Multi(
      [SqlFacet(MaxSize = -1)]
      SqlChars Input,
      [SqlFacet(MaxSize = 255)]
      SqlChars Delimiter
       )
    {
        return (
            (Input.IsNull || Delimiter.IsNull) ?
            new SplitStringMulti(new char[0], new char[0]) :
            new SplitStringMulti(Input.Value, Delimiter.Value));
    }

    public static void FillRow_Multi(object obj, out SqlString item)
    {
        item = new SqlString((string)obj);
    }

    public class SplitStringMulti : IEnumerator
    {
        public SplitStringMulti(char[] TheString, char[] Delimiter)
        {
            theString = TheString;
            stringLen = TheString.Length;
            delimiter = Delimiter;
            delimiterLen = (byte)(Delimiter.Length);
            isSingleCharDelim = (delimiterLen == 1);

            lastPos = 0;
            nextPos = delimiterLen * -1;
        }

        #region IEnumerator Members

        public object Current
        {
            get
            {
                return new string(theString, lastPos, nextPos - lastPos);
            }
        }

        public bool MoveNext()
        {
            if (nextPos >= stringLen)
                return false;
            else
            {
                lastPos = nextPos + delimiterLen;

                for (int i = lastPos; i < stringLen; i++)
                {
                    bool matches = true;

                    //Optimize for single-character delimiters
                    if (isSingleCharDelim)
                    {
                        if (theString[i] != delimiter[0])
                            matches = false;
                    }
                    else
                    {
                        for (byte j = 0; j < delimiterLen; j++)
                        {
                            if (((i + j) >= stringLen) || (theString[i + j] != delimiter[j]))
                            {
                                matches = false;
                                break;
                            }
                        }
                    }

                    if (matches)
                    {
                        nextPos = i;

                        //Deal with consecutive delimiters
                        if ((nextPos - lastPos) > 0)
                            return true;
                        else
                        {
                            i += (delimiterLen - 1);
                            lastPos += delimiterLen;
                        }
                    }
                }

                lastPos = nextPos + delimiterLen;
                nextPos = stringLen;

                if ((nextPos - lastPos) > 0)
                    return true;
                else
                    return false;
            }
        }

        public void Reset()
        {
            lastPos = 0;
            nextPos = delimiterLen * -1;
        }

        #endregion

        private int lastPos;
        private int nextPos;

        private readonly char[] theString;
        private readonly char[] delimiter;
        private readonly int stringLen;
        private readonly byte delimiterLen;
        private readonly bool isSingleCharDelim;
    }
};