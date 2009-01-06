<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/knowledge_base/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

boolean preview = ParamUtil.getBoolean(request, "preview");

boolean template = ParamUtil.getBoolean(request, "template");

// Article

KBArticle article = (KBArticle)request.getAttribute(KnowledgeBaseKeys.ARTICLE);

String title = BeanParamUtil.getString(article, request, "title");

String content = BeanParamUtil.getString(article, request, "content");

boolean draft = BeanParamUtil.getBoolean(article, request, "draft", true);

long parentResourcePrimKey = BeanParamUtil.getLong(article, request, "parentResourcePrimKey");

KBArticle parent = null;

long resourcePrimKey = 0;

if (article != null) {
	resourcePrimKey = BeanParamUtil.getLong(article, request, "resourcePrimKey");

	template = BeanParamUtil.getBoolean(article, request, "template", false);
}

if (parentResourcePrimKey > 0) {
	parent = KBArticleLocalServiceUtil.getArticle(parentResourcePrimKey);
}

// Templates

List<KBArticle> templates = KBArticleLocalServiceUtil.getGroupArticles(scopeGroupId, true, true, false);

//Portlet URLs

ResourceURL templateURL = renderResponse.createResourceURL();
%>

<script type="text/javascript">
	function <portlet:namespace />applyTemplate() {
		document.<portlet:namespace />fm.<portlet:namespace />addTemplate.value = "true";

		<portlet:namespace />saveAndContinueArticle();
	}

	function <portlet:namespace />getSuggestionsContent() {
		var content = '';

		content += document.<portlet:namespace />fm.<portlet:namespace/>title.value + ' ';
		content += window.<portlet:namespace />editor.getHTML();

		return content;
	}

	function <portlet:namespace />getTemplate() {
		var templateResourcePrimKey = "";

		templateResourcePrimKey = document.<portlet:namespace />fm['<portlet:namespace />templates'].value;

		document.<portlet:namespace />fm.<portlet:namespace />templateResourcePrimKey.value = templateResourcePrimKey;

		Liferay.KnowledgeBase.getTemplate(templateResourcePrimKey);
	}

	function <portlet:namespace />initEditor() {
		return "<%= UnicodeFormatter.toString(content) %>";
	}

	function <portlet:namespace />previewArticle() {
		document.<portlet:namespace />fm.<portlet:namespace />preview.value = "true";

		if (window.<portlet:namespace />editor) {
			document.<portlet:namespace />fm.<portlet:namespace />content.value = window.<portlet:namespace />editor.getHTML();
		}

		submitForm(document.<portlet:namespace />fm);
	}

	function <portlet:namespace />saveAndContinueArticle() {
		document.<portlet:namespace />fm.<portlet:namespace />saveAndContinueRedirect.value = "<portlet:renderURL><portlet:param name="view" value="edit_article" /></portlet:renderURL>";

		<portlet:namespace />saveArticle('<%= draft %>');
	}

	function <portlet:namespace />saveArticle(draft) {
		document.<portlet:namespace />fm.<portlet:namespace />actionName.value = "<%= Constants.UPDATE %>";
		document.<portlet:namespace />fm.<portlet:namespace />draft.value = draft;

		if (window.<portlet:namespace />editor) {
			document.<portlet:namespace />fm.<portlet:namespace />content.value = window.<portlet:namespace />editor.getHTML();
		}

		submitForm(document.<portlet:namespace />fm);
	}
</script>

<c:if test="<%= article != null %>">
	<jsp:include page="/knowledge_base/views/article_tabs.jsp">
		<jsp:param name="tabs1" value="edit" />
	</jsp:include>
</c:if>

<c:if test="<%= preview && (article != null) %>">

	<liferay-ui:message key="preview" />:

	<div class="preview">
		<h1 class="article-title">
			<%= title %>
		</h1>
		<div class="knowledge-base-body">
			<%= content %>
		</div>
	</div>

	<br />
</c:if>

<form action="<portlet:actionURL />" method="post" name="<portlet:namespace />fm">
<input name="<portlet:namespace />actionName" type="hidden" value="" />
<input name="<portlet:namespace />addTemplate" type="hidden" value="" />
<input name="<portlet:namespace />draft" type="hidden" value="" />
<input name="<portlet:namespace />templateResourcePrimKey" type="hidden" value="" />
<input name="<portlet:namespace />redirect" type="hidden" value="<%= HtmlUtil.escape(redirect) %>" />
<input name="<portlet:namespace />template" type="hidden" value="<%= template %>" />
<input name="<portlet:namespace />parentResourcePrimKey" type="hidden" value="<%= parentResourcePrimKey %>" />
<input name="<portlet:namespace />resourcePrimKey" type="hidden" value="<%= resourcePrimKey %>" />

<c:if test="<%= article != null %>">
	<input name="<portlet:namespace />version" type="hidden" value="<%= article.getVersion() %>" />
</c:if>

<input name="<portlet:namespace />preview" type="hidden" value="0" />
<input name="<portlet:namespace />saveAndContinueRedirect" type="hidden" value="" />

<liferay-ui:error exception="<%= ArticleTitleException.class %>" message="please-enter-a-valid-title" />
<liferay-ui:error exception="<%= ArticleVersionException.class %>" message="another-user-has-made-changes-since-you-started-editing-please-copy-your-changes-and-try-again" />
<liferay-ui:tags-error />

<table class="lfr-table">
<tr>
	<td>
		<liferay-ui:message key="title" />
	</td>
	<td>
		<input name="<portlet:namespace />title" size="80" type="text" value="<%= title %>" />
	</td>
</tr>
<c:if test="<%= parent != null %>">
	<tr>
		<td>
			<liferay-ui:message key="parent" />
		</td>
		<td>
			<%= parent.getTitle() %>
		</td>
	</tr>
</c:if>
</table>

<br />

<div>
	<liferay-ui:input-editor editorImpl="<%= null %>" width="100%" />

	<input name="<portlet:namespace />content" type="hidden" value="" />
</div>

<br />

<table class="lfr-table" width="100%">

<c:if test="<%= !templates.isEmpty() && !template %>">
	<tr>
		<td colspan="2">
			<liferay-ui:tabs names="templates" />
		</td>
	</tr>
	<tr>
		<td>
			<liferay-ui:message key="template" />
		</td>
		<td>
			<div class="template-preview" id="<portlet:namespace />templateContent" style="display: none;"></div>

			<select id="<portlet:namespace />templates" name="<portlet:namespace />templates" onChange="<portlet:namespace />getTemplate();">
				<option value=""></option>

				<%
				for (int i = 0; i < templates.size(); i++) {
					KBArticle currentTemplate = (KBArticle) templates.get(i);
				%>

					<option value="<%= String.valueOf(currentTemplate.getResourcePrimKey()) %>"><%= currentTemplate.getTitle() %></option>

				<%
				}
				%>

			</select>

			<span class="template-button-holder" id="<portlet:namespace />applyTemplateButton" style="display: none;">
				<input type="button" value='<liferay-ui:message key="apply" />' onClick="<portlet:namespace />applyTemplate();" /><liferay-ui:icon-help message="applying-a-template-will-not-delete-any-previous-work-in-this-article" />
			</span>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<br />
		</td>
	</tr>
</c:if>

<%
long classPK = 0;

if (article != null) {
	classPK = article.getResourcePrimKey();
}
%>

<c:if test="<%= !template %>">
	<tr>
		<td colspan="2">
			<liferay-ui:tabs names="details" />
		</td>
	</tr>
	<tr>
		<td>
			<liferay-ui:message key="categories" />
		</td>
		<td>
			<liferay-ui:tags-selector
				className="<%= KBArticle.class.getName() %>"
				classPK="<%= classPK %>"
				folksonomy="<%= false %>"
				hiddenInput="tagsCategories"
			/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<br />
		</td>
	</tr>
	<tr>
		<td>
			<liferay-ui:message key="tags" />
		</td>
		<td>
			<liferay-ui:tags-selector
				className="<%= KBArticle.class.getName() %>"
				classPK="<%= classPK %>"
				hiddenInput="tagsEntries"
				contentCallback='<%= renderResponse.getNamespace() + "getSuggestionsContent" %>'
			/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<br />
		</td>
	</tr>
	<tr>
		<td>
			<liferay-ui:message key="description" />
		</td>
		<td>
			<liferay-ui:input-field model="<%= KBArticle.class %>" bean="<%= article %>" field="description" />
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<br />
		</td>
	</tr>

	<c:if test="<%= !draft && !template %>">
		<tr>
			<td colspan="2">
				<input name="<portlet:namespace />minorEdit" type="checkbox" />

				<liferay-ui:message key="this-is-a-minor-edit" /><liferay-ui:icon-help message="leave-this-box-unchecked-to-email-subscribed-users-that-this-article-has-recently-been-updated" />
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<br />
			</td>
		</tr>
	</c:if>
</c:if>

</table>

<input type="button" value='<%= draft && !template ? LanguageUtil.get(pageContext, "publish") : LanguageUtil.get(pageContext, "save") %>' onClick="<portlet:namespace />saveArticle(false);" />

<c:if test="<%= draft && !template %>">
	<input type="button" value="<liferay-ui:message key="save-draft" />" onClick="<portlet:namespace />saveArticle(true);" />
</c:if>

<input type="button" value="<liferay-ui:message key="save-and-continue" />" onClick="<portlet:namespace />saveAndContinueArticle();" />

<input type="button" value="<liferay-ui:message key="preview" />" onClick="<portlet:namespace />previewArticle();" />

<input type="button" value="<liferay-ui:message key="cancel" />" onClick="document.location = '<%= HtmlUtil.escape(redirect) %>'" />

<c:if test="<%= draft && !template %>">
	<liferay-ui:icon-help message="this-article-will-be-viewable-to-other-users-only-after-clicking-the-publish-button" />
</c:if>

</form>

<script type="text/javascript">
	if (!window.<portlet:namespace />editor) {
		Liferay.Util.focusFormField(document.<portlet:namespace />fm.<portlet:namespace />title);
	}

	if (<%= !templates.isEmpty() && !template %>) {
		Liferay.KnowledgeBase.initEditArticle({
			namespace: '<portlet:namespace />',
			templateURL: '<%= templateURL %>'
		});
	}
</script>