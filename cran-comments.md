## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

> Please add \value to .Rd files regarding exported methods and explain
> the functions results in the documentation. Please write about the
> structure of the output (class) and also what the output means. (If a
> function does not return a value, please document that too, e.g.
> \value{No return value, called for side effects} or similar)
> Missing Rd-tags:
>       npm_audit.Rd: \value
>       npm_init.Rd: \value
>       npm_install.Rd: \value
>       npm_outdated.Rd: \value
>       npm_path.Rd: \value
>       npm_update.Rd: \value
> 
> Please fix and resubmit.

All exported functions have `\value`.
