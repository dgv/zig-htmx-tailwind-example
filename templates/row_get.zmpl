<tr id="datarow-{{.id}}" class="border-b dark:border-neutral-500">
  <td class="whitespace-nowrap px-6 py-4">{{.id}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{.company}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{.contact}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{.country}}</td>
  <td class="whitespace-nowrap px-1 py-1">
    <a
      hx-get="/company/edit/{{.id}}"
      hx-target="#datarow-{{.id}}"
      hx-swap="outerHTML"
      hx-indicator="#processing"
      class="hover:underline text-blue-700"
      href=""
    >
      Edit
    </a>
  </td>
  <td class="whitespace-nowrap px-1 py-1">
    <a
      hx-delete="/company/{{.id}}"
      hx-target="#companies"
      hx-confirm="Are you sure you want to delete {{.company}}?"
      hx-indicator="#processing"
      class="hover:underline text-blue-700"
      href=""
      >Delete</a
    >
  </td>
</tr>
