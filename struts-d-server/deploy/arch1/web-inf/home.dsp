<html>
<head>
</head>
<body>
<H1> Home </H1>
Bienvenue: <dsp:value value="user.name"/> <br/>
<table>
  <dsp:forEach item="itm" list="myList">
    <td>
      <li>
	<dsp:value value="itm"/>
      </li>
    </td>
  </dsp:forEach>
</table>
</body>
</html>
