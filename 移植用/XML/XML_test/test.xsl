<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>タイトル</title>
				<link rel="stylesheet" type="text/css" href="test.css"/>
			</head>
			<body>
				<table>
					<tr>
						<th>商品コード</th>
						<th>商品名</th>
						<th>単価</th>
					</tr>
					<xsl:apply-templates select="タイトル/非表示"/>
				</table>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="タイトル/非表示">
		<tr>
			<td><xsl:value-of select="商品コード"/></td>
			<td><xsl:value-of select="商品名"/></td>
			<td><xsl:value-of select="単価"/></td>
		</tr>
	</xsl:template>
</xsl:stylesheet>