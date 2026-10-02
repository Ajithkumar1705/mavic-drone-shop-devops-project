# Service Catalog

## Application services

| Service | Runtime | Responsibility | Primary dependencies |
|---|---|---|---|
| `web` | Nginx/static frontend | Web UI and frontend routing | backend services |
| `cart` | Node.js | Shopping cart | Redis, catalogue |
| `catalogue` | Node.js | Product catalogue | MongoDB |
| `user` | Node.js | User/session operations | MongoDB, Redis |
| `payment` | Python | Payment processing flow | cart, user, RabbitMQ |
| `shipping` | Java/Spring Boot | Shipping calculation/confirmation | MySQL, cart |
| `ratings` | PHP | Product ratings | MySQL, catalogue |
| `dispatch` | Go | Dispatch/event processing | RabbitMQ |

## Supporting services

| Service | Role |
|---|---|
| MongoDB | Catalogue/user document storage |
| MySQL | Relational data used by shipping/ratings |
| Redis | Session/cache/cart support |
| RabbitMQ | Asynchronous messaging |

## Repository model

Every application service has its own build context and Dockerfile. Stateless services are deployed using the reusable Helm chart:

```text
EKS/helm/service/
```

The supporting tier is maintained under:

```text
EKS/helm/infrastructure/
```

## Service-level delivery

CI detects changes by directory. CD accepts one service and one image tag, allowing targeted deployment.

See [CI/CD](CI-CD.md) and [Kubernetes Deployment](KUBERNETES-DEPLOYMENT.md).
