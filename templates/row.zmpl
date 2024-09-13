@for (.companies) |c| {
<tr id="datarow-{{c.id}}" class="border-b dark:border-neutral-500">
  <td class="whitespace-nowrap px-6 py-4">{{c.id}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{c.company}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{c.contact}}</td>
  <td class="whitespace-nowrap px-6 py-4">{{c.country}}</td>
  <td class="whitespace-nowrap px-1 py-1">
    <a hx-get="/company/edit/{{c.id}}" hx-target="#datarow-{{c.id}}" hx-swap="outerHTML"
      hx-indicator="#processing"
      class="hover:underline text-blue-700"
      href="" >Edit</a>
  </td>
  <td class="whitespace-nowrap px-1 py-1">
    <a hx-delete="/company/{{c.id}}" hx-target="#companies" hx-confirm="Are you sure you want to delete {{c.company}}?" hx-indicator="#processing" class="hover:underline text-blue-700" href="">Delete</a>
  </td>
</tr>
}
