function e(e){let t=[],n=e=>`  `.repeat(e);if(e.comments)for(let n of e.comments)String(n).trim().startsWith(`lastSavedUnix:`)||t.push(n);if(e.pluginStorage?.Runner?.variables?.length>0){t.push(`variables:`);for(let r of e.pluginStorage.Runner.variables)t.push(`${n(1)}- key: ${r.key}`),t.push(`${n(2)}value: ${r.value}`)}return t.map(e=>`// ${e}`).join(`
`)}function t(e){return e.replace(/\r\n/g,`
`)}function n(e){return[`title: ${e.title}`,`tags: ${e.tags}`,`position: ${e.position.x},${e.position.y}`,`colorID: ${e.colorID}`,`---`,t(e.body),`===
`].join(`
`)}function r(t){let r=t,i=e(r.header),a=r.nodes.map(n).join(`
`);return i===``?a:`${i}\n\n${a}`}function i(e){let t={},n=[],r=!1,i={};for(let a of e){let e=a.replace(/^\/\/\s?/,``).trim().replace(/\s+/,` `);if(e===`variables:`)r=!0;else if(r&&e.startsWith(`- key:`))Object.keys(i).length>0&&(n.push(i),i={}),i.key=e.slice(6).trim();else if(r&&e.startsWith(`value:`)){let t=e.slice(6).trim();i.value=t}else t.comments?t.comments.push(e):t.comments=[e]}return Object.keys(i).length>0&&n.push(i),n.length>0&&(t.pluginStorage={Runner:{variables:n}}),t}function a(e){return e.replace(/\r\n/g,`
`).split(/^===\s*$/m).map(e=>e.trim()).filter(Boolean).map(e=>{let[t,...n]=e.split(/^---\s*$/m),r=t.split(`
`).map(e=>e.trim()),i=n.join(`
`).trim(),a=``,o=``,s={x:0,y:0},c=0;for(let e of r)if(e.startsWith(`title:`))a=e.slice(6).trim();else if(e.startsWith(`tags:`))o=e.slice(5).trim();else if(e.startsWith(`position:`)){let[t,n]=e.slice(9).trim().split(`,`).map(e=>e.trim()).map(Number);s={x:t,y:n}}else e.startsWith(`colorID:`)&&(c=parseInt(e.slice(8).trim()));return{title:a,tags:o,position:s,colorID:c,body:i}})}function o(e){let t=e.replace(/\r\n/g,`
`).split(`
`),n=[],r=0;for(;r<t.length;){let e=t[r].trim();if(e.startsWith(`//`))n.push(e);else if(e!==``)break;r++}let o=t.slice(r),s;try{s=i(n)}catch(e){console.error(e)}s??={};let c=o.join(`
`),l;try{l=a(c)}catch(e){console.error(e)}return l??=[],{header:s,nodes:l}}export{o as n,r as t};